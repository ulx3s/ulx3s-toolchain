#!/bin/bash
echo "Setting permissions for all scripts in $(pwd)"

for file in ./*.sh
do
  echo "chmod +x $file"
  chmod +x  "$file"
done

 
