#!/bin/bash
# Describtion: Automatic build and test

Root_Dir=$(pwd)

# move to build file
test -e "$Root_Dir/src/abc" || (echo "ABC bot found"; exit 1)
cd $Root_Dir/src/abc

# compile
echo "# Compiling..."
make
if [ $? -ne 0 ]; then
	exit 1
fi

# run self unit test
echo "# Unit testing..."
TEMP_EXE=$Root_Dir/src/abc/abc
$TEMP_EXE -q "utest"
if [ $? -ne 0 ]; then
	exit 1
fi

# run each testcases
echo "# Benchmark testing..."
TEMP_EXE=$Root_Dir/src/abc/abc

CASES_DIR=$Root_Dir/testcases/case
RESULT_DIR=$Root_Dir/testcases/result
test -e "$Root_Dir/testcases" || mkdir "$Root_Dir/testcases"
test -e "$RESULT_DIR" || mkdir "$RESULT_DIR"

if [ -e $CASES_DIR ]; then
  CASE_LIST=$(ls $CASES_DIR)
  for file in $CASE_LIST; do
    ($TEMP_EXE -q "ssat_elim $CASES_DIR/$file") > $RESULT_DIR/$file.log
	cat $RESULT_DIR/$file.log
    # TODO: use verify program
  done
fi

# 
echo "All testing are passed: OK"


