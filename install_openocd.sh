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
#  Install openocd see https://github.com/ntfreak/openocd
#
# TODO - why does bootstrap fail on first execution?
#"***************************************************************************************************"
THIS_LOG=$LOG_DIRECTORY"/"$THIS_FILE_NAME"_openocd_"$LOG_SUFFIX".log"

sudo apt-get install libtool automake pkg-config libusb-1.0-0-dev  --assume-yes   2>&1 | tee -a "$THIS_LOG"

echo "***************************************************************************************************"
echo " openocd. Saving log to $THIS_LOG"
echo "***************************************************************************************************"
if [ ! -d "$WORKSPACE"/openocd ]; then
  git clone --recursive https://github.com/ntfreak/openocd.git    2>&1 | tee -a "$THIS_LOG"
  $SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"
  cd openocd
else
  cd openocd
  git fetch                                                       2>&1 | tee -a "$THIS_LOG"
  git pull                                                        2>&1 | tee -a "$THIS_LOG"
  $SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"
fi

echo "***************************************************************************************************"
echo " openocd bootstrap. Saving log to $THIS_LOG"
echo "***************************************************************************************************"

# hack alert! bootstrap seems to always fail the first time, so we'll run it without saving to log :/
./bootstrap

./bootstrap                                                       2>&1 | tee -a "$THIS_LOG"
$SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"

echo "***************************************************************************************************"
echo " openocd configure. Saving log to $THIS_LOG"
echo "***************************************************************************************************"
./configure --enable-ftdi                                         2>&1 | tee -a "$THIS_LOG"
$SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"

echo "***************************************************************************************************"
echo " openocd make. Saving log to $THIS_LOG"
echo "***************************************************************************************************"
make                                                              2>&1 | tee -a "$THIS_LOG"
$SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"

echo "***************************************************************************************************"
echo " openocd make install. Saving log to $THIS_LOG"
echo "***************************************************************************************************"
sudo make install                                                 2>&1 | tee -a "$THIS_LOG"
$SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"

echo "Completed $0 "                                                  | tee -a "$THIS_LOG"
