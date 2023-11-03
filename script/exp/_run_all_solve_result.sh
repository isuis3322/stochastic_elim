#!/bin/bash

TESTSCRIPT=0 # change this to 0 for real solve

# ========== Check Config ===============

# CASEDIR="../../../testcases/blif_binary_minimized_noobs"
: "${TIMELIMIT:=3600}"      # time limit to solve one case
: "${MEMLIMIT:=32000000}"   # memory limit to solve one case
: "${TIMEFRAMELIMIT:=1023}" # timeframe limit to solve one case, the default value 1023 is the theory limit of 5-states fsm

: "${ForceRun:=0}"        # 0: not solve if the rawlog exists, 1: solve even the rawlog exists
: "${RemoveTmpLog:=1}"    # 0: keep tmp log for debug, 1: remove tmp log
: "${parallel_limit:=10}" # how many cases can be solved in the same time

export CASEDIR
export TIMELIMIT
export MEMLIMIT
export TIMEFRAMELIMIT

export ForceRun
export RemoveTmpLog
export parallel_limit

export TESTSCRIPT
# ====== Main Function============
# bash ./run_my_ssat.sh      #
# bash ./run_neinze_ssat.sh      #
# bash ./run_dcssat.sh      #


bash ./run_my_ssat2.sh      #
bash ./run_neinze_ssat2.sh      #
bash ./run_dcssat2.sh      #
