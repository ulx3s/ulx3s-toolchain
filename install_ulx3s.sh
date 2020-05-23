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

# ensure we alwaye start from the $WORKSPACE directory
cd "$WORKSPACE"
#"***************************************************************************************************"
# install emard's repo of all the great ULX3S docs
#"***************************************************************************************************"

echo "***************************************************************************************************"
echo " emard's ULX3S PCB. Saving log to $THIS_LOG"
echo "***************************************************************************************************"

# Call the common github checkout:

$SAVED_CURRENT_PATH/fetch_github.sh https://github.com/emard/ulx3s ulx3s $THIS_CHECKOUT  2>&1 | tee -a "$THIS_LOG"
$SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"

cd ulx3s

# TODO - any checks here?

cd $SAVED_CURRENT_PATH

echo "Completed $0 "                                                  | tee -a "$THIS_LOG"
