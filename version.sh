#!/bin/bash
#"***************************************************************************************************"
#  common initialization
#"***************************************************************************************************"
# perform some version control checks on this file
./gitcheck.sh $0

# initialize some environment variables and perform some sanity checks (optional 1 keyowrd)
. ./init.sh

# we don't want tee to capture exit codes
set -o pipefail

#"***************************************************************************************************"
# 
#"***************************************************************************************************"
echo "***************************************************************************************************"
echo " show versions installed. Saving log to $THIS_LOG"
echo "***************************************************************************************************"
lsb_release -a                                                              2>&1 | tee -a "$THIS_LOG"
python  --version                                                           2>&1 | tee -a "$THIS_LOG"
python3 --version                                                           2>&1 | tee -a "$THIS_LOG"
cmake   --version                                                           2>&1 | tee -a "$THIS_LOG"
clang   --version                                                           2>&1 | tee -a "$THIS_LOG"
echo qtf_default $(apt-cache show qt5-default | grep -m1 Version)           2>&1 | tee -a "$THIS_LOG"
echo libboost-all-dev $(apt-cache show libboost-all-dev | grep -m1 Version) 2>&1 | tee -a "$THIS_LOG"

for pk in build-essential clang bison flex libreadline-dev \
		  gawk tcl-dev libffi-dev git mercurial graphviz   \
		  xdot pkg-config python python3 libftdi-dev \
		  qt5-default python3-dev libboost-dev; \
  do echo "$pk" $(apt-cache show "$pk" | grep -m1 Version 2>&1 | tee -a "$THIS_LOG");  done

nextpnr-ecp5 --version                                                      2>&1 | tee -a "$THIS_LOG"
$SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"

yosys -V                                                                    2>&1 | tee -a "$THIS_LOG"
$SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"

/opt/riscv32i/bin/riscv32-unknown-elf-gcc --version                         2>&1 | tee -a "$THIS_LOG"
$SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"

cd $SAVED_CURRENT_PATH

echo "Completed $0 "                                                             | tee -a "$THIS_LOG"
