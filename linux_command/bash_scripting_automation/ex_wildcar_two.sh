#!/bin/bash
# YYYY-MM-DD

#given file extension loop through filename and then rename it with prefix
#rename file with mv command: mv fold_path new_path
DATE=$(date +%F)
read -p "Please enter a file extension: " EXTENSION
read -p "Please enter a file prefix: (Press ENTER for ${DATE}). " PREFIX
if [ -z "$PREFIX" ]
then
  PREFIX="$DATE"
fi
for FILE in *.${EXTENSION}
do
  NEW_FILE="${PREFIX}-${FILE}"
  echo "Renaming $FILE to ${NEW_FILE}."
  mv $FILE ${NEW_FILE}
done