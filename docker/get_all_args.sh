#!/bin/bash

echo "Arguments: $@"

echo "Arguments two: $*"

if [ "${1:0:1}" = '-' ]; then
	set -- mysqld "$@"
fi
