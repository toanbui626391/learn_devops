#!/bin/bash

#set -x will display each command step and the result of it.
#set +x will close debug section
#we can also use set command with flag like -e, stop execution when command exit with code different than 0
#flag -v print shell input lines as they are read.
TEST_VAR="test"
set -x
echo $TEST_VAR
date
cat ex_case.sh
set +x
hostname
