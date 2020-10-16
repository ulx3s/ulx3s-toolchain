#!/bin/bash
#"***************************************************************************************************"
#  common initialization
#"***************************************************************************************************"

# select master or some GitHub hash version, and whether or not to force a clean
THIS_CHECKOUT=master
THIS_CLEAN=true

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

# see http://www.clifford.at/icestorm/

# Call the common github checkout:

pushd .
cd "$WORKSPACE"

$SAVED_CURRENT_PATH/fetch_github.sh https://github.com/cliffordwolf/icestorm.git icestorm $THIS_CHECKOUT  2>&1 | tee -a "$THIS_LOG"
$SAVED_CURRENT_PATH/check_for_error.sh                                                                      $?          "$THIS_LOG"

cd "$WORKSPACE"/icestorm

# optional clean
if [ "$THIS_CLEAN" == "true" ]; then  
  echo ""                                                          2>&1 | tee -a "$THIS_LOG"
  echo "make clean"                                                2>&1 | tee -a "$THIS_LOG"
  make clean                                                       2>&1 | tee -a "$THIS_LOG"
  $SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"
fi

make -j$(nproc)                                                    2>&1 | tee -a "$THIS_LOG"
$SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"

sudo make install                                                  2>&1 | tee -a "$THIS_LOG"
$SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"

popd
echo "Completed $0 "                                                    | tee -a "$THIS_LOG"
echo "----------------------------------"
