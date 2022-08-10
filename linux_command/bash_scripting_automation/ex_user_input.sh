#!/bin/bash
#using read command with flag p (prompt)
read -p "Enter a user name: " USER
echo "Archiving user: $USER"
# Lock the account
passwd –l $USER
# Create an archive of the home directory.
tar cf /archives/${USER}.tar.gz /home/${USER}
