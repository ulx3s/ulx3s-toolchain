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
#"***************************************************************************************************"
# Install nextpnr-ecp5
#"***************************************************************************************************"

echo "***************************************************************************************************"
echo " nextpnr-ecp5. Saving log to $THIS_LOG"
echo "***************************************************************************************************"
# see https://github.com/YosysHQ/nextpnr#nextpnr-ecp5

if [ "$APTGET" == 1 ]; then
  sudo apt-get install python3-pip --assume-yes    2>&1 | tee -a "$THIS_LOG"
  sudo apt-get install libboost-all-dev python3-dev qt5-default clang-format libeigen3-dev --assume-yes 2>&1 | tee -a "$THIS_LOG"
  # Is this one really needed?
  sudo apt-get install libboost-filesystem-dev libboost-thread-dev libboost-program-options-dev libboost-python-dev libboost-iostreams-dev libboost-dev  --assume-yes 2>&1 | tee -a "$THIS_LOG"
  sudo apt-get install cmake --assume-yes                          2>&1 | tee -a "$THIS_LOG"
fi

THIS_ARCH=$1

if [ "$THIS_ARCH" == "" ]; then
  THIS_ARCH=ecp5
fi

pushd .
cd "$WORKSPACE"

# Call the common github checkout:
$SAVED_CURRENT_PATH/fetch_github.sh https://github.com/YosysHQ/nextpnr.git nextpnr $THIS_CHECKOUT  2>&1 | tee -a "$THIS_LOG"
$SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"

cd "$WORKSPACE"/nextpnr

# optional clean
# if [ "$THIS_CLEAN" == "true" ]; then  
#   echo ""                                                          2>&1 | tee -a "$THIS_LOG"
#   echo "make clean"                                                2>&1 | tee -a "$THIS_LOG"
#   make clean                                                       2>&1 | tee -a "$THIS_LOG"
#   $SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"
# fi

# Note the "DTRELLIS_INSTALL_PREFIX=/usr" value is the install directory, not git workspace clone directory
# If CMake fails, try rm CMakeCache.txt
#
# See for https://github.com/YosysHQ/nextpnr/issues/215#issuecomment-456053526
# for -DBUILD_PYTHON=OFF -DBUILD_GUI=OFF and  "cannot find -lpthreads" error
#
# note that it is a hack, and is likely sweeping problems under the carpet.
# see https://github.com/YosysHQ/nextpnr/pull/443#issuecomment-630456185
#
# cmake -DARCH=$THIS_ARCH -DBUILD_PYTHON=OFF -DBUILD_GUI=OFF -DTRELLIS_INSTALL_PREFIX=/usr .           2>&1 | tee -a "$THIS_LOG"
#

cmake -DARCH=$THIS_ARCH  -DTRELLIS_INSTALL_PREFIX=/usr .         2>&1 | tee -a "$THIS_LOG"
echo This error: $?
$SAVED_CURRENT_PATH/check_for_error.sh $? "./CMakeFiles/CMakeOutput.log" "./CMakeFiles/CMakeError.log"

# if this is currently failing with
# [ 17%] Generating ecp5/chipdbs/chipdb-25k.bba
# Traceback (most recent call last):
#   File "/home/gojimmypi/workspace/nextpnr/ecp5/trellis_import.py", line 3, in <module>
#     import database
# ModuleNotFoundError: No module named 'database'
# see https://stackoverflow.com/questions/9383014/cant-import-my-own-modules-in-python
# to fix:
# export PYTHONPATH="~/workspace/prjtrellis/database"
# or check trellis params

make -j$(nproc)                                                  2>&1 | tee -a "$THIS_LOG"
$SAVED_CURRENT_PATH/check_for_error.sh $? "./CMakeFiles/CMakeOutput.log" "./CMakeFiles/CMakeError.log"

sudo make install                                                2>&1 | tee -a "$THIS_LOG"
$SAVED_CURRENT_PATH/check_for_error.sh $?


# hack to fix error: nextpnr-ecp5: error while loading shared libraries: libQt5Core.so.5: cannot open shared object file: No such file or directory
nextpnr-$THIS_ARCH --version                                     2>&1 | tee -a "$THIS_LOG"
EXIT_STAT=$?

if [ $EXIT_STAT -ne 0 ];then
  echo ""
  echo "Warning: nextpnr-$THIS_ARCH problem detected!"           2>&1 | tee -a "$THIS_LOG"
  echo ""
  NEXTMSG="$(nextpnr-$THIS_ARCH --version 2>&1)"

  if [ "$NEXTMSG" == "nextpnr-ecp5: error while loading shared libraries: libQt5Core.so.5: cannot open shared object file: No such file or directory" ]; then
    while true; do
      echo "Do you wish to try to fix libQt5Core.so.5 with:"
      echo ""
      echo "  strip --remove-section=.note.ABI-tag ?"
      echo ""
      read -p "Try this?" yn
      case $yn in
          [Yy]* ) echo "Fixing!"
                  echo "Searching for libQt5Core.so.5 in /usr/. ..."
                  THIS_LIB=$(find /usr/. -name "libQt5Core.so.5")
                  echo "Found: $THIS_LIB"
                  sudo strip --remove-section=.note.ABI-tag "$THIS_LIB"
                  break;;
          [Nn]* ) echo "Fix NOT applied."; break;;
          * ) echo "Please answer yes or no.";;
      esac
    done

    # echo "Fixing libQt5Core.so.5 with: strip --remove-section=.note.ABI-tag /usr/./lib/x86_64-linux-gnu/libQt5Core.so.5"

    # sudo strip --remove-section=.note.ABI-tag /usr/./lib/x86_64-linux-gnu/libQt5Core.so.5
    nextpnr-$THIS_ARCH --version
    EXIT_STAT=$?

    if [ $EXIT_STAT -ne 0 ];then
      echo "ERROR: Fix failed."
    else
      echo "Fix was successful!"
    fi
  else
    echo "ERROR: No fix is avilable at this time."
  fi
else
  echo "nextpnr-$1 success!"
fi

# sudo strip --remove-section=.note.ABI-tag /usr/./lib/x86_64-linux-gnu/libQt5Core.so.5

popd
echo "Completed $0 "                                                  | tee -a "$THIS_LOG"
echo "----------------------------------"
