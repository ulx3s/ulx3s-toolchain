#!/bin/bash
#"***************************************************************************************************"
#  common initialization
#"***************************************************************************************************"
# perform some version control checks on this file
./gitcheck.sh $0

# initialize some environment variables and perform some sanity checks
. ./init.sh ujprog

# we don't want tee to capture exit codes
set -o pipefail

#"***************************************************************************************************"
# Install ujprog from f32c (used to upload binaries to ULX3S)
#"***************************************************************************************************"
echo "***************************************************************************************************"
echo " ujprog. Saving log to $THIS_LOG"
echo "***************************************************************************************************"

sudo apt-get install libftdi1-dev libusb-dev cmake make build-essential --assume-yes 2>&1 | tee -a "$THIS_LOG"


# NOTE: Although this successfully compiles, it does not seem to work in WSL (no USB device support, use EXE instead)
if [ ! -d "$WORKSPACE"/fujprog ]; then
  git clone https://github.com/kost/fujprog.git                  2>&1 | tee -a "$THIS_LOG"
  $SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"
  cd fujprog
else
  cd fujprog
  git fetch                                                      2>&1 | tee -a "$THIS_LOG"
  git pull                                                       2>&1 | tee -a "$THIS_LOG"
  $SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"

  # there's currently no "make clean"
  # make clean                                                     2>&1 | tee -a "$THIS_LOG"
  # $SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"
fi

# There's no point to making the linux version of ujprog in WSL, as native USB devices are not supported.
# but we can compile the Windows version, amd actually call it from WSL (call from /mnt/c... not ~/...)
if grep -q Microsoft /proc/version; then
  echo "***************************************************************************************************"
  echo " ming32_64. Saving log to $THIS_LOG"
  echo "***************************************************************************************************"

  # wget https://www.ftdichip.com/Drivers/CDM/CDM%20v2.12.28%20WHQL%20Certified.zip

  mkdir -p build
  cd build
  cmake -DCMAKE_TOOLCHAIN_FILE=`pwd`/../cmake/Toolchain-cross-mingw32.cmake ..
  make
  $SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"
else
  mkdir -p build
  cd build
  cmake ..                                                       2>&1 | tee -a "$THIS_LOG"
  make                                                           2>&1 | tee -a "$THIS_LOG"

  make install                                                   2>&1 | tee -a "$THIS_LOG"
  $SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"
fi

cd $SAVED_CURRENT_PATH

echo "Completed $0 "                                                  | tee -a "$THIS_LOG"
