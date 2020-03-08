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
echo " arachne-pnr. Saving log to $THIS_LOG"
echo "***************************************************************************************************"
if [ ! -d "$WORKSPACE"/arachne-pnr ]; then
  git clone https://github.com/cseed/arachne-pnr.git arachne-pnr 2>&1 | tee -a "$THIS_LOG"
  cd arachne-pnr
else
  cd arachne-pnr
  git fetch                                                      2>&1 | tee -a "$THIS_LOG" 
  git pull                                                       2>&1 | tee -a "$THIS_LOG"
  $SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"

  make clean                                                     2>&1 | tee -a "$THIS_LOG" 
  $SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"
fi

make -j$(nproc)                                                  2>&1 | tee -a "$THIS_LOG"
$SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"

sudo make install                                                2>&1 | tee -a "$THIS_LOG"
$SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"

cd $SAVED_CURRENT_PATH

echo "Completed $0 "                                                  | tee -a "$THIS_LOG"
