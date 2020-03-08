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
# 
#"***************************************************************************************************"

echo "***************************************************************************************************"
echo " openocd-esp32. Saving log to $THIS_LOG"
echo "***************************************************************************************************"
if [ ! -d "$WORKSPACE"/openocd-esp32 ]; then
  git clone --recursive https://github.com/espressif/openocd-esp32    2>&1 | tee -a "$THIS_LOG"
  cd openocd-esp32
else
  cd openocd-esp32
  git fetch                                                       2>&1 | tee -a "$THIS_LOG"
  git pull                                                        2>&1 | tee -a "$THIS_LOG"
  $SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"
fi

echo "Completed $0 "                                                  | tee -a "$THIS_LOG"
