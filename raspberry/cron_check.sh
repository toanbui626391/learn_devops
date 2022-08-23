#!/bin/bash
#if cron service is running. it will return 0, if cron service is not run status code is 3
#get status code of previous command line use $?
#fi means finish if
# remember syntax error with value assignment to variable.
# rember syntax error with if condition testing
status_code=$(service cron status)
if [ $? -eq 0 ]
then
    echo "cron service is running"
else
    echo "cron serviceis is not running. Restart cron service!"
    service cron restart
fi