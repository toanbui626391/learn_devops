#!/bin/bash

#using exit to specify return code of your script
#return code "0" means success from 1-255 means fail
HOST="google.com"
ping -c 1 $HOST
if [ "$?" -ne "0" ]
then
  echo "$HOST unreachable."
  exit 1
fi
  exit 0