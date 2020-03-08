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
#  check for minimum system resources needed (typically 40GB new Ubuntu VM with 5GB RAM)
#"***************************************************************************************************"
if [ $(free | grep Mem | awk '{ print $2 }') -lt $MIN_ULX3S_MEMORY ]; then
  echo ""
  echo "System memory found:"
  free
  echo ""
  read -p "Warning: At least $MIN_ULX3S_MEMORY bytes of memory is needed. Press a key to continue"
fi

echo "Install all ULX3S toolchains. Edit parameters in init.sh"
echo ""
echo "logs saved to $LOG_DIRECTORY" 
echo ""
echo ""
read -p "Press enter to continue, or Ctrl-C to abort."

chmod +x install_set_permissions.sh
./install_set_permissions.sh

./install_system.sh

./install_ulx3s-bin.sh

./install_esp32.sh
./install_openocd-esp32.sh

./install_riscv-gnu-toolchain-rv32i.sh
./install_picorv32_riscv32i.sh
./install_openocd.sh

./install_yosys.sh
./install_prjtrellis.sh
./install_nextpnr.sh
./install_arachne-pnr.sh

./install_verilator.sh
./install_icestorm.sh
./install_litex.sh

./install_ujprog.sh
./install_blinky.sh
./install_fpga_odysseus.sh
./install_rxrbln-picorv32.sh

echo "***************************************************************************************************"
echo "update current system again. Saving log to $THIS_LOG"
echo "***************************************************************************************************"
sudo apt-get update --assume-yes        2>&1 | tee -a "$THIS_LOG"

echo "Completed $0 " | tee -a "$THIS_LOG"
