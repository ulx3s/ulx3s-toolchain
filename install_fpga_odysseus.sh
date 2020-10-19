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
# fpga-odysseus example
#"***************************************************************************************************"

# Call the common github checkout:

pushd .
cd "$WORKSPACE"

$SAVED_CURRENT_PATH/fetch_github.sh https://github.com/ulx3s/fpga-odysseus.git fpga-odysseus $THIS_CHECKOUT  2>&1 | tee -a "$THIS_LOG"
$SAVED_CURRENT_PATH/check_for_error.sh                                                                         $?          "$THIS_LOG"

popd
echo "Completed $0 "                                                  | tee -a "$THIS_LOG"
echo "----------------------------------"
