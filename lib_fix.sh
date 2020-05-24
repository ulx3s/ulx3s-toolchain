#!/bin/bash
#
# prompt to fix libQt5Core.so.5
# 
    while true; do
      echo "Do you wish to try to fix libQt5Core.so.5 with:"
      echo ""
      echo "  strip --remove-section=.note.ABI-tag ?"
      echo ""
      read -p "Try this?" yn
      case $yn in
          [Yy]* ) echo "Fixing!"
                  echo "Searching for libQt5Core.so.5 ..."
                  THIS_LIB=$(find /usr/. -name "libQt5Core.so.5")
                  echo "Found: $THIS_LIB"
                  sudo strip --remove-section=.note.ABI-tag "$THIS_LIB"
                  break;;
          [Nn]* ) echo "Fix NOT applied."; break;;
          * ) echo "Please answer yes or no.";;
      esac
    done
