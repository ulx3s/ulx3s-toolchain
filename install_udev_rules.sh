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
# Install udev rules
#"***************************************************************************************************"
cd ulx3s-toolchain

# see https://github.com/emard/ulx3s-bin

if [ -f "/etc/udev/rules.d/80-fpga-ulx3s.rules" ]; then
  echo "Found /etc/udev/rules.d/80-fpga-ulx3s.rules ... skipping copy."   2>&1 | tee -a "$THIS_LOG"
else
  echo "Copy /etc/udev/rules.d/80-fpga-ulx3s.rules"                       2>&1 | tee -a "$THIS_LOG"
  sudo cp 80-fpga-ulx3s.rules /etc/udev/rules.d/80-fpga-ulx3s.rules       2>&1 | tee -a "$THIS_LOG"
  $SAVED_CURRENT_PATH/check_for_error.sh   $?          "$THIS_LOG"
fi
