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



./install_set_permissions.sh


./install_verilator.sh
./install_yosys.sh


./install_nexptpnr-ecp5.sh

./install_fujprog.sh

