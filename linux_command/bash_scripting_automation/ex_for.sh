#!/bin/bash
#for example one
for COLOR in red green blue
do
  echo "COLOR: $COLOR"
done
#for exampel two:
COLORS="red green blue"
for COLOR in $COLORS
do
  echo "COLOR: $COLOR"
done
# example syntax for
PICTURES=$(ls *jpg)
DATE=$(date +%F)
for PICTURE in $PICTURES
do
  echo "Renaming ${PICTURE} to ${DATE}-${PICTURE}"
  mv ${PICTURE} ${DATE}-${PICTURE}
done