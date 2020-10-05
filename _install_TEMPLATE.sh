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

echo "***************************************************************************************************" | tee -a "$THIS_LOG"
echo " Install TEMPLATE. Saving log to $THIS_LOG"                                                          | tee -a "$THIS_LOG"
echo "***************************************************************************************************" | tee -a "$THIS_LOG"

# Call the common github checkout:

$SAVED_CURRENT_PATH/fetch_github.sh https://github.com/gojimmypi/TEMPLATE.git TEMPLATE $THIS_CHECKOUT  2>&1 | tee -a "$THIS_LOG"
$SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"

cd TEMPLATE

# optional clean
if [ "$THIS_CLEAN" == "true" ]; then  
  echo ""                                                          2>&1 | tee -a "$THIS_LOG"
  echo "make clean"                                                2>&1 | tee -a "$THIS_LOG"
  make clean                                                       2>&1 | tee -a "$THIS_LOG"
  $SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"
fi

# optional WSL detection
if grep -q ?Microsoft /proc/version; then
  echo "WSL!"
else
  echo "Non-WSL"
fi

# make
echo ""                                                            2>&1 | tee -a "$THIS_LOG"
echo "make"                                                        2>&1 | tee -a "$THIS_LOG"
make                                                               2>&1 | tee -a "$THIS_LOG"
$SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"

# make install
echo ""                                                            2>&1 | tee -a "$THIS_LOG"
echo "sudo make install"                                           2>&1 | tee -a "$THIS_LOG"
sudo make install                                                  2>&1 | tee -a "$THIS_LOG"
$SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"

cd $SAVED_CURRENT_PATH

echo "Completed $0"                                                     | tee -a "$THIS_LOG"
