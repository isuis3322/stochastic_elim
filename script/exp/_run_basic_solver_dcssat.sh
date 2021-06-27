#!/bin/bash

# this script can not be used directly, but only be called by other script with config setting

# ========== Check Config ===============
: "${CASEDIR:?}"
CASEPATTERN="*.sdimacs"
: "${LOGDIR:?}"
# : "${QDIMACSDIR:?}"
ABC="../../bin/DC-SSAT/dcssat"
: "${HSADAPT:=0}"
: "${HSCOMPLEMT:=0}"
: "${USEQCIR:=0}"
# : "${EXE:="homing"}" # ABC command
# : "${EXECFLAG:="-n 3"}" # flag for the command
BLOQQER="../../../bin/bloqqer"
: "${USEBLOQQER:=0}"
# : "${SOLVER:?}"
# : "${SOLVERFLAG:=""}"
: "${TIMELIMIT:?}"
: "${MEMLIMIT:=32000000}"
: "${INFO_COLLECT_FILE:?}"
: "${SATInfoString:?}"
: "${UNSATInfoString:?}"

: "${ForceRun:=1}"
: "${RemoveTmpLog:=1}"
: "${parallel_limit:=1}"

: "${TIMEFRAMELIMIT:=1023}"

: "${TESTSCRIPT:=0}"

export CASEDIR
export CASEPATTERN
# export QDIMACSDIR
export LOGDIR
export INFO_COLLECT_FILE

export ABC
export HSADAPT
export HSCOMPLEMT
export USEQCIR
# export EXE
# export EXECFLAG
export BLOQQER
export USEBLOQQER
# export SOLVER
# export SOLVERFLAG
export SATInfoString
export UNSATInfoString

export TIMELIMIT
export MEMLIMIT
export ForceRun
export RemoveTmpLog
# export parallel_limit

export TESTSCRIPT

# ==== Helping Function =============
# replace $str1 by $str2 in $str
#  echo $str | sed "s|$str1|$str2|g"
#
function extractInfo() {
    infoLeading=$1
    logFile=$2
    local result
    result=$(grep "^$infoLeading" "$logFile" | sed "s/^.*$infoLeading//g" | sed 's/(.*)//g' | sed 's/^[ \t]*//;s/[ \t]*$//')
    echo "$result"
}
export -f extractInfo

function extractInfoLast() {
    infoLeading=$1
    logFile=$2
    local result
    result=$(grep "^$infoLeading" "$logFile" | tail -1 | sed "s/^.*$infoLeading//g" | sed 's/(.*)//g' | sed 's/^[ \t]*//;s/[ \t]*$//')
    echo "$result"
}
export -f extractInfoLast

function findInfo() {
    infoLeading=$1
    logFile=$2
    local result
    result=$(grep "^$infoLeading" "$logFile" | sed 's/^[ \t]*//;s/[ \t]*$//')
    echo "$result"
}
export -f findInfo

# =================
function IsBloqqerTO() {
    TMPLOGFILE=$1
    local result
    result=$(findInfo "*** bloqqer: out of time" "$TMPLOGFILE")
    if [ "$result" != "" ]; then
        echo 1
    fi
}
export -f IsBloqqerTO

function IsMemoryOut() {
    TMPLOGFILE=$1
    local result
    result=$(findInfo "MEM" "$TMPLOGFILE")
    if [ "$result" != "" ]; then
        echo 1
    fi
}
export -f IsMemoryOut

function IsTimeOut() {
    TMPLOGFILE=$1
    local result
    result=$(findInfo "TIMEOUT" "$TMPLOGFILE")
    if [ "$result" != "" ]; then
        echo 1
    fi
}
export -f IsTimeOut

function IsSatisfiable() {
    TMPLOGFILE=$1
    local result
    result=$(findInfo "$SATInfoString" "$TMPLOGFILE")
    if [ "$result" != "" ]; then
        echo 1
    fi
}
export -f IsSatisfiable

function IsUnsatisfiable() {
    TMPLOGFILE=$1
    local result
    result=$(findInfo "$UNSATInfoString" "$TMPLOGFILE")
    if [ "$result" != "" ]; then
        echo 1
    fi
}
export -f IsUnsatisfiable

# ====== check before solve ============
if [ ! -x "$ABC" ]; then
    echo "can not find executable ABC: $ABC"
    exit
fi
if [ "$USEBLOQQER" == 1 ]; then
    echo "bloqqer does not support for ABC using"
    exit
fi
# ====== setting before solve ============
if [ "$HSADAPT" == 1 ]; then
    echo "ABC can not solve adapt HS"
    exit
    AdaptFLAG="-A"
else
    AdaptFLAG=""
fi
export AdaptFLAG
if [ "$USEQCIR" == 1 ]; then
    QCIRFLAG="-Q"
else
    QCIRFLAG=""
fi
export QCIRFLAG

# ====== Main Function============
function solve() {
    CASEFILE=$1
    LOGFILE="${CASEFILE//$CASEDIR/$LOGDIR}.log"

    echo $LOGFILE

    # create folder for log file
    test -e "$(dirname "$LOGFILE")" || mkdir -p "$(dirname "$LOGFILE")"
    # if not $ForceRun and log file exists, do nothing
    if [ "$ForceRun" == "0" ]; then
        test -e "$LOGFILE" && return
    fi
    # remove log file if exists
    rm -f "$LOGFILE"

    totoalruntime=0
    totoalpreprocesstime=0
    # for i in $(seq 1 $TIMEFRAMELIMIT); do

        # time -p (resourcelimit -t "$TIMELIMIT" -m "$MEMLIMIT" "$ABC" -q "ssat -v $CASEFILE") >"$LOGFILE.tmp" 2>&1
        time -p (resourcelimit -t "$TIMELIMIT" -m "$MEMLIMIT" "$ABC" "$CASEFILE") >"$LOGFILE" 2>&1

        if [[ $(IsMemoryOut "$LOGFILE") ]]; then
            # runtime=$(extractInfo "real" "$LOGFILE.tmp")
            # totoalruntime=$(echo "$totoalruntime" "$runtime" | awk '{printf("%.2f", $1 + $2)}')
            {
                echo "s MO"
                # echo "real $totoalruntime"
                # echo "pre $totoalpreprocesstime"
            } >>"$LOGFILE"
            # break
        fi

        # if [[ $(IsSatisfiable "$LOGFILE.tmp") ]]; then
        #     runtime=$(extractInfo "real" "$LOGFILE.tmp")
        #     totoalruntime=$(echo "$totoalruntime" "$runtime" | awk '{printf("%.2f", $1 + $2)}')
        #     {
        #         echo "find HS with length: $i"
        #         echo "s cnf 1"
        #         echo "real $totoalruntime"
        #         echo "pre $totoalpreprocesstime"
        #     } >>"$LOGFILE"
        #     break
        # fi

        # if [[ $(IsUnsatisfiable "$LOGFILE.tmp") ]]; then
        #     runtime=$(extractInfo "real" "$LOGFILE.tmp")
        #     totoalruntime=$(echo "$totoalruntime" "$runtime" | awk '{printf("%.2f", $1 + $2)}')
        #     TIMELIMIT=$(echo "$TIMELIMIT" "$runtime" | awk '{printf("%.2f", $1 - $2)}')

        #     echo "No HS with length: $i" >>"$LOGFILE"
        #     continue
        # fi

        # Time out
        # {
        #     echo "s cnf TO"
        #     echo "real $totoalruntime"
        #     echo "pre $totoalpreprocesstime"
        # } >>"$LOGFILE"
        # break
    # done
    if [ "$RemoveTmpLog" == 1 ]; then
        rm -f "$LOGFILE.tmp"
    fi
}
export -f solve
# ==================================
function collectInfo() {
    CASEFILE=$1

    LOGFILE="${CASEFILE//$CASEDIR/$LOGDIR}.log"

    if [ ! -f "$LOGFILE" ]; then
        echo "can not find : $LOGFILE"
        return
    fi

    # Case name, solve result, run time, ...
    echo -n "$(echo "$LOGFILE" | sed "s|$LOGDIR/||g" | sed "s|/|_|g")" >>"$INFO_COLLECT_FILE"

    result=$(extractInfo "s " "$LOGFILE")
    echo -n ",$result" >>"$INFO_COLLECT_FILE"

    result=$(extractInfo "Pr\[SAT\]                  =" "$LOGFILE")
    if [ "$result" != "" ]; then
        echo -n ",$result" >>"$INFO_COLLECT_FILE"
    else
        echo -n ",-1" >>"$INFO_COLLECT_FILE"
        # result=$(extractInfoLast "No HS with length:" "$LOGFILE")
        # if [ "$result" != "" ]; then
        #     echo -n ",$result" >>"$INFO_COLLECT_FILE"
        # else
        #     echo -n ",0" >>"$INFO_COLLECT_FILE"
        # fi
    fi

    result=$(extractInfo "real" "$LOGFILE")
    echo -n ",$result" >>"$INFO_COLLECT_FILE"

    result=$(extractInfo "pre" "$LOGFILE")
    if [ "$result" != "" ]; then
        echo ",$result" >>"$INFO_COLLECT_FILE"
    else
        echo ",0" >>"$INFO_COLLECT_FILE"
    fi
}
export -f collectInfo

# execution
find "$CASEDIR" -type f -name "$CASEPATTERN" | parallel --jobs $parallel_limit solve {}

# result collection
echo "case,result,upper,lower,time,pretime" >"$INFO_COLLECT_FILE"
find "$CASEDIR" -type f -name "$CASEPATTERN" | parallel --jobs 1 collectInfo {}
