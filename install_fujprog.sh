#!/bin/bash
#"***************************************************************************************************"
#  common initialization
#"***************************************************************************************************"
#
# select master or some GitHub hash version, and whether or not to force a clean
THIS_CHECKOUT=master
THIS_CLEAN=true

# ff78bd2f3
# perform some version control checks on this file
./gitcheck.sh $0

# initialize some environment variables and perform some sanity checks
. ./init.sh

# we don't want tee to capture exit codes
set -o pipefail

#"***************************************************************************************************"
# Install fujprog from f32c (used to upload binaries to ULX3S)
#"***************************************************************************************************"
echo "***************************************************************************************************"
echo " fujprog. Saving log to $THIS_LOG"
echo "***************************************************************************************************"

if [ "$APTGET" == 1 ]; then
  sudo apt-get install libftdi1-dev libusb-dev cmake make build-essential --assume-yes 2>&1 | tee -a "$THIS_LOG"
fi

pushd .
cd "$WORKSPACE"

$SAVED_CURRENT_PATH/fetch_github.sh https://github.com/kost/fujprog.git fujprog $THIS_CHECKOUT  2>&1 | tee -a "$THIS_LOG"
$SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"

cd "$WORKSPACE"/fujprog

# There's no point to making the linux version of fujprog in WSL, as native USB devices are not supported.
# but we can compile the Windows version, amd actually call it from WSL (call from /mnt/c... not ~/...)
if grep -q Microsoft /proc/version; then
  echo "***************************************************************************************************"
  echo " ming32_64. Saving log to $THIS_LOG"
  echo "***************************************************************************************************"

  wget --no-hsts https://www.ftdichip.com/Drivers/CDM/CDM%20v2.12.28%20WHQL%20Certified.zip

  mkdir -p build
  cd build
  cmake -DCMAKE_TOOLCHAIN_FILE=`pwd`/../cmake/Toolchain-cross-mingw32.cmake ..
  make
  echo "fujprog.exe is in $WORKSPACE/fujprog/build"
  $SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"
else
  mkdir -p build
  cd build
  cmake ..                                                       2>&1 | tee -a "$THIS_LOG"
  make -j$(nproc)                                                2>&1 | tee -a "$THIS_LOG"

  sudo make install                                              2>&1 | tee -a "$THIS_LOG"
  $SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"
fi

popd
echo "Completed $0"                                                   | tee -a "$THIS_LOG"
echo "----------------------------------"
