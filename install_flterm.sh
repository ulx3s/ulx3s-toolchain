#!/bin/bash
#"***************************************************************************************************"
#  common initialization
#"***************************************************************************************************"

# select master or some GitHub hash version, and whether or not to force a clean
THIS_CHECKOUT=master
THIS_CLEAN=true

# perform some version control checks on this file
./gitcheck.sh $0

# initialize some environment variables and perform some sanity checks (optional 1 keyowrd)
. ./init.sh

# we don't want tee to capture exit codes
set -o pipefail

# ensure we alwaye start from the $WORKSPACE directory
cd "$WORKSPACE"
#"***************************************************************************************************"
# desc
#"***************************************************************************************************"

echo "***************************************************************************************************"
echo " timvideos/flterm. Saving log to $THIS_LOG"
echo "***************************************************************************************************"

# Call the common github checkout:

$SAVED_CURRENT_PATH/fetch_github.sh https://github.com/timvideos/flterm.git flterm $THIS_CHECKOUT  2>&1 | tee -a "$THIS_LOG"
$SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"

cd flterm

# optional clean
if [ "$THIS_CLEAN" == "true" ]; then  
  echo ""                                                          2>&1 | tee -a "$THIS_LOG"
  echo "make clean"                                                2>&1 | tee -a "$THIS_LOG"
  make clean                                                       2>&1 | tee -a "$THIS_LOG"
  $SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"
fi

make
$SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"

cd $SAVED_CURRENT_PATH

