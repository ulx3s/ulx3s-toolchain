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
# Install nextpnr-ecp5
#"***************************************************************************************************"

echo "***************************************************************************************************"
echo " nextpnr-ecp5. Saving log to $THIS_LOG"
echo "***************************************************************************************************"
# see https://github.com/YosysHQ/nextpnr#nextpnr-ecp5

sudo apt-get install python3-pip --assume-yes
# pip3 install database

sudo apt-get install libboost-all-dev python3-dev qt5-default clang-format libeigen3-dev --assume-yes 2>&1 | tee -a "$THIS_LOG"

# Is this one really needed?
sudo apt-get install libboost-filesystem-dev libboost-thread-dev libboost-program-options-dev libboost-python-dev libboost-iostreams-dev libboost-dev  --assume-yes 2>&1 | tee -a "$THIS_LOG"

sudo apt-get install cmake --assume-yes                          2>&1 | tee -a "$THIS_LOG"

THIS_ARCH=$1

if [ "$THIS_ARCH" == "" ]; then
  THIS_ARCH=ecp5
fi


if [ ! -d "$WORKSPACE"/nextpnr ]; then
  git clone https://github.com/YosysHQ/nextpnr.git               2>&1 | tee -a "$THIS_LOG"
  $SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"
  cd nextpnr
else
  cd nextpnr
  git fetch                                                      2>&1 | tee -a "$THIS_LOG"
  git pull                                                       2>&1 | tee -a "$THIS_LOG"
  $SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"

  make clean                                                     2>&1 | tee -a "$THIS_LOG"
  $SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG" "./CMakeFiles/CMakeOutput.log" "./CMakeFiles/CMakeError.log"
fi

# Note the "DTRELLIS_INSTALL_PREFIX=/usr" value is the install directory, not git workspace clone directory
# If CMake fails, try rm CMakeCache.txt
#
# See for https://github.com/YosysHQ/nextpnr/issues/215#issuecomment-456053526
# for -DBUILD_PYTHON=OFF -DBUILD_GUI=OFF and  "cannot find -lpthreads" error

cmake -DARCH=$THIS_ARCH -DBUILD_PYTHON=OFF -DBUILD_GUI=OFF -DTRELLIS_INSTALL_PREFIX=/usr .           2>&1 | tee -a "$THIS_LOG"

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

cd $SAVED_CURRENT_PATH

echo "Completed $0 "                                                  | tee -a "$THIS_LOG"
