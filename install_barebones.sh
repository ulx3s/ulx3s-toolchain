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

# ./init.sh leaves us at the $WORKSPACE directory, so change to ulx3s-toolchain
cd ulx3s-toolchain

./install_set_permissions.sh


./install_verilator.sh
./install_yosys.sh


./install_nexptpnr.sh ecp5

./install_fujprog.sh

