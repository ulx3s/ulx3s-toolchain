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
# fetch and install yoysys
#"***************************************************************************************************"

sudo apt-get install build-essential clang bison flex \
	libreadline-dev gawk tcl-dev libffi-dev git \
	graphviz xdot pkg-config python3 libboost-system-dev \
	libboost-python-dev libboost-filesystem-dev zlib1g-dev  --assume-yes   2>&1 | tee -a "$THIS_LOG"

# see https://github.com/YosysHQ/nextpnr/issues/375 for 18.04
# sudo strip --remove-section=.note.ABI-tag /usr/lib/x86_64-linux-gnu/libQt5Core.so.5

# See https://github.com/microsoft/WSL/issues/3023#issuecomment-452281015

# https://github.com/BVLC/caffe/issues/410#issuecomment-196546857
# export CPLUS_INCLUDE_PATH=/usr/include/python2.7

echo "***************************************************************************************************"
echo " yosys. Saving log to $THIS_LOG"
echo "***************************************************************************************************"
# see http://www.clifford.at/yosys/
if [ ! -d "$WORKSPACE"/yosys ]; then
  git clone https://github.com/cliffordwolf/yosys.git yosys      2>&1 | tee -a "$THIS_LOG"
  $SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"
  cd yosys
else
  cd yosys
  git fetch                                                      2>&1 | tee -a "$THIS_LOG"
  git pull                                                       2>&1 | tee -a "$THIS_LOG" 
  $SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"

  # TODO optional clean
  make clean                                                     2>&1 | tee -a "$THIS_LOG"
  $SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"
fi

make                                                             2>&1 | tee -a "$THIS_LOG"
$SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"

sudo make install                                                2>&1 | tee -a "$THIS_LOG"
$SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"

cd $SAVED_CURRENT_PATH

echo "Completed $0 "                                                  | tee -a "$THIS_LOG"
