#!/bin/bash
cd /var/www
for FILE in /var/www/*.html
do
  echo "Copying $FILE"
  cp $FILE /var/www-just-html
done