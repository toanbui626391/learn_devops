#!/bin/bash
# Optional:
# Uncomment the following line to avoid an error when no jpg files are found.
# shopt -s nullglob
# YYYY-MM-DD
DATE=$(date +%F)
#loop through jpg file in the current directory
for FILE in *.jpg
do
  #mv $FILE ${DATE}-${FILE}
  echo $FILE
done