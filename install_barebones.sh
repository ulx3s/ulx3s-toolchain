#!/bin/bash
#"***************************************************************************************************"
#  common initialization
#"***************************************************************************************************"
#
# perform some version control checks on this file
./gitcheck.sh $0

# initialize some environment variables and perform some sanity checks
. ./init.sh

# we don't want tee to capture exit codes
set -o pipefail

cd "$WORKSPACE"/ulx3s-toolchain
echo "Barebone install!"
pwd

./install_set_permissions.sh

# system updates and dependencies
./install_system.sh

# set udev rules
./install_udev_rules.sh

./install_verilator.sh
./install_yosys.sh

./install_prjtrellis.sh

./install_nextpnr.sh ecp5

./install_fujprog.sh

