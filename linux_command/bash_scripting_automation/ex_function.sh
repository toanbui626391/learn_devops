#!/bin/bash
#define function with syntax
function hello() {
    echo "Hello!"
    #call function inside a function
    now
}

function now() {
    echo "It's $(date +%r)"
}

#call function
hello