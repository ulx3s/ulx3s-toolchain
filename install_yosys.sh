#!/bin/bash
#"***************************************************************************************************"
#  common initialization
#"***************************************************************************************************"
THIS_CHECKOUT=master
THIS_CLEAN=true
# 93ef516d919
# af7b7b6dc18919 interesting error

# perform some version control checks on this file
./gitcheck.sh $0

# initialize some environment variables and perform some sanity checks
. ./init.sh

# we don't want tee to capture exit codes
set -o pipefail

#"***************************************************************************************************"
# fetch and install yoysys
#"***************************************************************************************************"

if [ "$APTGET" == 1 ]; then
  sudo apt-get install build-essential clang bison flex \
    libreadline-dev gawk tcl-dev libffi-dev git \
    graphviz xdot pkg-config python3 libboost-system-dev \
    libboost-python-dev libboost-filesystem-dev zlib1g-dev  --assume-yes   2>&1 | tee -a "$THIS_LOG"
fi

pushd .
cd $WORKSPACE

echo "***************************************************************************************************"
echo " yosys. Saving log to $THIS_LOG"
echo "***************************************************************************************************"
$SAVED_CURRENT_PATH/fetch_github.sh https://github.com/cliffordwolf/yosys.git yosys $THIS_CHECKOUT  2>&1 | tee -a "$THIS_LOG"
$SAVED_CURRENT_PATH/check_for_error.sh                                              $?                            "$THIS_LOG"

cd "$WORKSPACE"/yosys

# optional clean
if [ "$THIS_CLEAN" == "true" ]; then  
  echo ""                                                          2>&1 | tee -a "$THIS_LOG"
  echo "make clean"                                                2>&1 | tee -a "$THIS_LOG"
  make clean                                                       2>&1 | tee -a "$THIS_LOG"
  $SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"
fi

echo ""                                                            2>&1 | tee -a "$THIS_LOG"
echo "make"                                                        2>&1 | tee -a "$THIS_LOG"
make -j$(nproc)                                                    2>&1 | tee -a "$THIS_LOG"
$SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"

echo ""                                                            2>&1 | tee -a "$THIS_LOG"
echo "sudo make install"                                           2>&1 | tee -a "$THIS_LOG"
sudo make install                                                  2>&1 | tee -a "$THIS_LOG"
$SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"

echo ""                                                                 | tee -a "$THIS_LOG"
yosys --version                                                         | tee -a "$THIS_LOG"
echo ""                                                                 | tee -a "$THIS_LOG"

popd
echo "Completed $0 "                                                    | tee -a "$THIS_LOG"
echo "----------------------------------"
