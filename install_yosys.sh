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
# fetch and install yoysys
#"***************************************************************************************************"

echo "***************************************************************************************************"
echo " yosys. Saving log to $THIS_LOG"
echo "***************************************************************************************************"
# see http://www.clifford.at/yosys/
if [ ! -d "$WORKSPACE"/yosys ]; then
  git clone https://github.com/cliffordwolf/yosys.git yosys      2>&1 | tee -a "$THIS_LOG"
  $SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"
  cd yosys
else
  cd yosys
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
