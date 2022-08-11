#!/bin/bash

#access return code with $? and compare operation with -eq or ne
#$? return string78
HOST="google.com"
ping -c 1 $HOST
if [ "$?" -eq "0" ]
then
    echo "$HOST reachable."
else
    echo "$HOST unreachable."
fi
#second example of access return code with $? and compare operation with -ne
HOST="google.com"
ping -c 1 $HOST
RETURN_CODE=$?
if [ "$RETURN_CODE" -ne "0" ]
then
echo "$HOST unreachable."
fi