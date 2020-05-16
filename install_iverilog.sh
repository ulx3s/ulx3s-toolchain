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
# icestorm
#"***************************************************************************************************"
echo "***************************************************************************************************"
echo " icestorm. Saving log to: "$THIS_LOG
echo "***************************************************************************************************"
sudo apt-get install autoconf gperf                               2>&1 | tee -a "$THIS_LOG"


if [ ! -d "$WORKSPACE"/iverilog ]; then
  git clone https://github.com/steveicarus/iverilog.git           2>&1 | tee -a "$THIS_LOG"
  $SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"
  cd iverilog
else
  cd iverilog
  git fetch                                                       2>&1 | tee -a "$THIS_LOG"
  git pull                                                        2>&1 | tee -a "$THIS_LOG"
  $SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"

  make clean                                                      2>&1 | tee -a "$THIS_LOG"
  $SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"
fi

sh autoconf.sh                                                    2>&1 | tee -a "$THIS_LOG"
./configure                                                       2>&1 | tee -a "$THIS_LOG"
make                                                              2>&1 | tee -a "$THIS_LOG"
$SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"


sudo make install                                                 2>&1 | tee -a "$THIS_LOG"
$SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"

cd $SAVED_CURRENT_PATH

echo "Completed $0 "                                                  | tee -a "$THIS_LOG"
