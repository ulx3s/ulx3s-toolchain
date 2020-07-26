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
# Install prjtrellis
#"***************************************************************************************************"
sudo apt-get install python3-dev clang cmake                     2>&1 | tee -a "$THIS_LOG"


echo "***************************************************************************************************"
echo " prjtrellis (required for nextpnr-ecp5). Saving log to $THIS_LOG"
echo "***************************************************************************************************"

# Call the common github checkout:

$SAVED_CURRENT_PATH/fetch_github.sh https://github.com/YosysHQ/prjtrellis prjtrellis $THIS_CHECKOUT  2>&1 | tee -a "$THIS_LOG"
$SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"

cd prjtrellis

source environment.sh

# cmake must run from the libtrellis directory
cd libtrellis

# Makefile will not exist the very first time, so nothing to do
# optional clean
if [ "$THIS_CLEAN" == "true" ]; then  
  if [ ! -f "Makefile" ]; then
    echo "$0: File 'Makefile' not found. Not cleaning... (probably a fresh git clone)"
  else
    echo ""                                                          2>&1 | tee -a "$THIS_LOG"
    echo "make clean"                                                2>&1 | tee -a "$THIS_LOG"
    make clean                                                     2>&1 | tee -a "$THIS_LOG"
    $SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"
  fi
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
