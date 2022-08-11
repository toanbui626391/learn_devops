#!/bin/bash
function file_count() {
  local NUMBER_OF_FILES=$(ls | wc -l)
  echo "$NUMBER_OF_FILES"
}
file_count

function file_count_v2() {
local DIR=$1
local NUMBER_OF_FILES=$(ls $DIR | wc -l)
echo "${DIR}:"
echo "$NUMBER_OF_FILES"
}
file_count /etc
file_count /var
file_count /usr/bin