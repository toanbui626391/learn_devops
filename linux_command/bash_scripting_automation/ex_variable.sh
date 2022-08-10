#!/bin/bash
#assign value to variable, get value from a variable
MY_SHELL="bash"
#firt syntax to get varialbe name with syntax: $varialbe_name
echo "I like the $MY_SHELL shell."
#second syntax to get value of variable with ${variable_name}
echo "I like the ${MY_SHELL} shell"
#get value from command and assign to a variable.
#get value from hostname command and assign to variable. $(command)
SERVER_NAME=$(hostname)
echo "You are running this script on ${SERVER_NAME}."
#older syntax to get value from command and assign to variable
SERVER_NAME=`hostname`
echo "You are running this script on ${SERVER_NAME}."