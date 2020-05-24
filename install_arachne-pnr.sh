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

cd "$WORKSPACE"
#"***************************************************************************************************"
# arachne-pnr
#"***************************************************************************************************"
echo "***************************************************************************************************"
echo " arachne-pnr. Saving log to $THIS_LOG"
echo "***************************************************************************************************"


# Call the common github checkout:

$SAVED_CURRENT_PATH/fetch_github.sh https://github.com/cseed/arachne-pnr.git arachne-pnr $THIS_CHECKOUT  2>&1 | tee -a "$THIS_LOG"
$SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"

cd arachne-pnr

# optional clean
if [ "$THIS_CLEAN" == "true" ]; then  
  echo ""                                                          2>&1 | tee -a "$THIS_LOG"
  echo "make clean"                                                2>&1 | tee -a "$THIS_LOG"
  make clean                                                       2>&1 | tee -a "$THIS_LOG"
  $SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"
fi

make                                                             2>&1 | tee -a "$THIS_LOG"
$SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"

sudo make install                                                2>&1 | tee -a "$THIS_LOG"
$SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"

cd $SAVED_CURRENT_PATH

echo "Completed $0 "                                                  | tee -a "$THIS_LOG"
