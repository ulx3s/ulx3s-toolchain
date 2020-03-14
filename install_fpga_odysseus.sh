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
# fpga-odysseus example
#"***************************************************************************************************"

echo "***************************************************************************************************"
echo " fpga-odysseus. Saving log to $THIS_LOG"
echo "***************************************************************************************************"
if [ ! -d "$WORKSPACE"/fpga-odysseus ]; then
  git clone --recursive https://github.com/ulx3s/fpga-odysseus.git 2>&1 | tee -a "$THIS_LOG"
  $SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"
  cd fpga-odysseus
else
  cd fpga-odysseus
  git fetch                                                       2>&1 | tee -a "$THIS_LOG"
  git pull                                                        2>&1 | tee -a "$THIS_LOG"
  $SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"
fi

cd $SAVED_CURRENT_PATH

echo "Completed $0 "                                                  | tee -a "$THIS_LOG"
