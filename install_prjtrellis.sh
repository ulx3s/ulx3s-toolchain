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

# ensure we alwaye start from the $WORKSPACE directory
cd "$WORKSPACE"
#"***************************************************************************************************"
# Install prjtrellis
#"***************************************************************************************************"

echo "***************************************************************************************************"
echo " prjtrellis (required for nextpnr-ecp5). Saving log to $THIS_LOG"
echo "***************************************************************************************************"
if [ ! -d "$WORKSPACE"/prjtrellis ]; then
  git clone --recursive https://github.com/SymbiFlow/prjtrellis
  $SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"
  cd prjtrellis
else
  cd prjtrellis
  git fetch                                                      2>&1 | tee -a "$THIS_LOG"
  git pull                                                       2>&1 | tee -a "$THIS_LOG"
  $SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"
fi

# cmake must run from the libtrellis directory
cd libtrellis

# Makefile will not exist the very first time, so nothing to do
if [ ! -f "Makefile" ]; then
  echo "$0: File 'Makefile' not found. Not cleaning..."
else
  make clean                                                     2>&1 | tee -a "$THIS_LOG"
  $SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"
fi

cmake -DCMAKE_INSTALL_PREFIX=/usr .                              2>&1 | tee -a "$THIS_LOG"
$SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"

# see https://stackoverflow.com/questions/9383014/cant-import-my-own-modules-in-python
# now set above
# export PYTHONPATH="~/workspace/prjtrellis/database"

make                                                             2>&1 | tee -a "$THIS_LOG"
$SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"

sudo make install                                                2>&1 | tee -a "$THIS_LOG"
$SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"


cd $SAVED_CURRENT_PATH

echo "Completed $0 "                                                  | tee -a "$THIS_LOG"
