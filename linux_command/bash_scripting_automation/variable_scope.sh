#!/bin/bash
my_function() {
  GLOBAL_VAR=1
}
# GLOBAL_VAR not available yet.
echo $GLOBAL_VAR
my_function
# GLOBAL_VAR is NOW available.
echo $GLOBAL_VAR
#use keyword local to define a local variable, which means that we can only access variable inside function 