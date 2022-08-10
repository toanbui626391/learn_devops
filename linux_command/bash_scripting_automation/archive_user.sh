#!/bin/bash
#bash shell positional argument from $0-$9
#script name is also position argument at $0
echo "Executing script: $0"
echo "Archiving user: $1"
# Lock the account
passwd –l $1
# Create an archive of the home directory.
tar cf /archives/${1}.tar.gz /home/${1}