#!/bin/bash
#"***************************************************************************************************"
#  common initialization
#"***************************************************************************************************"
# perform some version control checks on this file
./gitcheck.sh $0

# initialize some environment variables and perform some sanity checks
. ./init.sh

# we don't want tee to capture exit codes
set -o pipefail

#"***************************************************************************************************"
# install verilator and dependencies
#"***************************************************************************************************"

echo "***************************************************************************************************"
echo "install verilator. Saving log to $THIS_LOG"
echo "***************************************************************************************************"
# The following NEW packages will be installed:
#  verilator
# 0 upgraded, 1 newly installed, 0 to remove and 1 not upgraded.
# Need to get 2878 kB of archives.
# After this operation, 13.1 MB of additional disk space will be used.
sudo apt-get install verilator --assume-yes    2>&1 | tee -a "$THIS_LOG"
$SAVED_CURRENT_PATH/check_for_error.sh           $? "$THIS_LOG"

if grep -q Microsoft /proc/version; then
  echo "***************************************************************************************************"
  echo "WSL detected; Install x86_64-w64-mingw32-gcc; Saving log to $THIS_LOG"
  echo "***************************************************************************************************"
  sudo apt-get install mingw-w64 --assume-yes  2>&1 | tee -a "$THIS_LOG"
  $SAVED_CURRENT_PATH/check_for_error.sh         $?          "$THIS_LOG"
fi

echo "Completed $0 "                                | tee -a "$THIS_LOG"
