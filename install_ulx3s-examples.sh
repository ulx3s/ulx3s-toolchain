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
# fetch the ULX3S examples into the workspace
#"***************************************************************************************************"
THIS_LOG=$LOG_DIRECTORY"/"$THIS_FILE_NAME"_ulx3s-bin_"$LOG_SUFFIX".log"

echo "***************************************************************************************************"
echo " ulx3s-examples. Saving log to $THIS_LOG"
echo "***************************************************************************************************"
if [ ! -d "$WORKSPACE"/ulx3s-examples ]; then
  git clone --recursive https://github.com/ulx3s/ulx3s-examples.git    2>&1 | tee -a "$THIS_LOG"
  $SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"
  cd ulx3s-examples
else
  cd ulx3s-examples
  git fetch                                                            2>&1 | tee -a "$THIS_LOG"
  git pull                                                             2>&1 | tee -a "$THIS_LOG"
  $SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"
fi

cd $SAVED_CURRENT_PATH

echo "Completed $0 "                                                  | tee -a "$THIS_LOG"
