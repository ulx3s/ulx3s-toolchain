#!/bin/bash
# because Visual Studio can still be annoying.... (but see CRLF/LF in lower right of file open in IDE, should be LF)
dos2unix --version > /dev/null 2>&1
if [ "$?" != "0" ]; then
  echo "installing dos2unix..."
  sudo apt-get install dos2unix --assume-yes
fi

echo "Converting all *.sh files..."

for file in ./*.sh
do
  dos2unix "$file"
done

