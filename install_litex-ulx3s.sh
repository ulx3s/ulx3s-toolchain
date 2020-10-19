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
# Run LiteX make for the ULX3S
#"***************************************************************************************************"
echo "***************************************************************************************************"
echo " install_litex-ulx3s. Saving log to $THIS_LOG"
echo "***************************************************************************************************"

. ./set_riscv_path.sh

# note we called init.sh when setting the path, so we are back in the $WORKSPACE directory now

pushd .
cd "$WORKSPACE"/linux-on-litex-vexriscv

if [ "$THIS_ULX3S_DEVICE" == "" ]; then
  export THIS_ULX3S_DEVICE=LFE5U-85F                                  2>&1 | tee -a "$THIS_LOG"
  echo "THIS_ULX3S_DEVICE not defined. Setting to $THIS_ULX3S_DEVICE" 2>&1 | tee -a "$THIS_LOG"
fi

# call make.py for linux-on-litex-vexriscv
echo "calling make.py --board ULX3S from $(pwd)"                      2>&1 | tee -a "$THIS_LOG"
./make.py --board ULX3S                                               2>&1 | tee -a "$THIS_LOG"
$SAVED_CURRENT_PATH/check_for_error.sh                                  $?          "$THIS_LOG"


# call ulx3s.py for litex-boards; targets are migen-hardware level definitions
# this imports the ulx3s.py pin-level contraints found in ../platform
cd "$WORKSPACE"/litex-boards/litex_boards/targets
echo "calling ./ulx3s.py --device $THIS_ULX3S_DEVICE from $(pwd)"     2>&1 | tee -a "$THIS_LOG"
./ulx3s.py --device $THIS_ULX3S_DEVICE                                2>&1 | tee -a "$THIS_LOG"
$SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"

# TODO see https://github.com/litex-hub/litex-renode#usage
# python3 ulx3s.py --cpu-type vexriscv  --csr-csv csr.csv

popd
echo "Completed $0 "                                                       | tee -a "$THIS_LOG"
echo "----------------------------------"
