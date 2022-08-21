#!/bin/bash

#define function with positional parameter
function hello() {
    #get and use positional parameter
    echo "Hello $1"
}
hello Jason

function hello() {
  for NAME in $@
  do
    echo "Hello $NAME"
  done
}

hello Jason Dan Ryan