#!/bin/bash

if [ "$THIS_SKIP_CZ" == "" ]; then 
  ./check_cz.sh
  if [ "$?" == "0" ]; then
    export THIS_SKIP_CZ="false"
  else
    export THIS_SKIP_CZ="true"
  fi
  echo "$0 Set THIS_SKIP_CZ=$THIS_SKIP_CZ"
else
  echo "$0 Found THIS_SKIP_CZ=$THIS_SKIP_CZ"
fi

if [ "$THIS_SKIP_CZ" == "true" ]; then
  echo ""
  echo "Skipping install_openocd since it needs access to https://repo.or.cz; THIS_SKIP_CZ=$THIS_SKIP_CZ"
  echo ""
  exit 0
fi

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
#  Install openocd see https://github.com/ntfreak/openocd
#
# TODO - why does bootstrap fail on first execution?
#"***************************************************************************************************"
THIS_LOG=$LOG_DIRECTORY"/"$THIS_FILE_NAME"_openocd_"$LOG_SUFFIX".log"

if [ "$APTGET" == 1 ]; then
  sudo apt-get install libtool automake pkg-config libusb-1.0-0-dev  --assume-yes                  2>&1 | tee -a "$THIS_LOG"
fi

echo "***************************************************************************************************"
echo " openocd. Saving log to $THIS_LOG"
echo "***************************************************************************************************"
# Call the common github checkout:

pushd .
cd "$WORKSPACE"

$SAVED_CURRENT_PATH/fetch_github.sh https://github.com/ntfreak/openocd.git openocd $THIS_CHECKOUT  2>&1 | tee -a "$THIS_LOG"
$SAVED_CURRENT_PATH/check_for_error.sh                                                               $?          "$THIS_LOG"

cd "$WORKSPACE"/openocd

# optional clean
# if [ "$THIS_CLEAN" == "true" ]; then  
#   echo ""                                                          2>&1 | tee -a "$THIS_LOG"
#   echo "make clean"                                                2>&1 | tee -a "$THIS_LOG"
#   make clean                                                       2>&1 | tee -a "$THIS_LOG"
#   $SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"
# fi

echo "***************************************************************************************************"
echo " openocd bootstrap. Saving log to $THIS_LOG"
echo "***************************************************************************************************"

# hack alert! bootstrap seems to always fail the first time, so we'll run it without saving to log :/
./bootstrap

./bootstrap                                                                                        2>&1 | tee -a "$THIS_LOG"
$SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"

echo "***************************************************************************************************"
echo " openocd configure. Saving log to $THIS_LOG"
echo "***************************************************************************************************"
./configure --enable-ftdi                                                                          2>&1 | tee -a "$THIS_LOG"
$SAVED_CURRENT_PATH/check_for_error.sh                                                               $?          "$THIS_LOG"

echo "***************************************************************************************************"
echo " openocd make. Saving log to $THIS_LOG"
echo "***************************************************************************************************"
make -j$(nproc)                                                                                    2>&1 | tee -a "$THIS_LOG"
$SAVED_CURRENT_PATH/check_for_error.sh                                                               $?          "$THIS_LOG"

echo "***************************************************************************************************"
echo " openocd make install. Saving log to $THIS_LOG"
echo "***************************************************************************************************"
sudo make install                                                 2>&1 | tee -a "$THIS_LOG"
$SAVED_CURRENT_PATH/check_for_error.sh                              $?          "$THIS_LOG"

popd
echo "Completed $0 "                                                  | tee -a "$THIS_LOG"
echo "----------------------------------"
