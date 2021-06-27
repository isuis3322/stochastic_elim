#!/bin/bash

TESTSCRIPT=1 # change this to 0 for real solve

# ========== Check Config ===============
: "${CASEDIR:="../../testcases/ssat-benchmarks"}"         # folder of input
: "${LOGDIR:="../../exp/ssat-benchmarks/nianze/rawlog"}"                # folder to store raw log
: "${INFO_COLLECT_FILE:="../../exp/ssat-benchmarks/nianze/result.csv"}" # file to store this exp result

: "${USEBLOQQER:=0}" # 0: no bloqqer, 1: use bloqqer
: "${USEQCIR:=0}"    # 0: QDimacs, 1: QCIR

: "${SATInfoString:="s SATISFIABLE"}"   # output string if the solver SAT
: "${UNSATInfoString:="s UNSATISFIABLE"}" # output string if the solver UNSAT

: "${TIMELIMIT:=3600}"      # time limit to solve one case
: "${MEMLIMIT:=32000000}"   # memory limit to solve one case
: "${TIMEFRAMELIMIT:=1023}" # timeframe limit to solve one case, the default value 1023 is the theory limit of 5-states fsm

: "${ForceRun:=0}"       # 0: not solve if the rawlog exists, 1: solve even the rawlog exists
: "${RemoveTmpLog:=1}"   # 0: keep tmp log for debug, 1: remove tmp log
: "${parallel_limit:=1}" # how many cases can be solved in the same time

export CASEDIR
export LOGDIR
export INFO_COLLECT_FILE

export USEBLOQQER
export USEQCIR

# export HSCOMPLEMT
export SATInfoString
export UNSATInfoString

export TIMELIMIT
export MEMLIMIT
export TIMEFRAMELIMIT

export ForceRun
export RemoveTmpLog
export parallel_limit

export TESTSCRIPT
# ====== Main Function============
bash ./_run_basic_solver_nianze.sh
