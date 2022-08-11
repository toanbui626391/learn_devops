#!/bin/bash

#set -x will display each command step and the result of it.
#set +x will close debug section
TEST_VAR="test"
set -x
echo $TEST_VAR
date
cat ex_case.sh
set +x
hostname
