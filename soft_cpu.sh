#!/bin/bash

cd /mnt/c/workspace/ulx3s-toolchain/ 

export PATH=$PATH:/opt/riscv32i/bin

# TODO why is this here:
export WORKSPACE=/mnt/c/workspace
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
# Soft CPU and BIOS
#"***************************************************************************************************"

# make the soft CPU
cd "$WORKSPACE"/litex-boards/litex_boards/targets

# $THIS_ULX3S_DEVICE contains a value such as LFE5U-85F
./ulx3s.py --device $THIS_ULX3S_DEVICE --cpu-type picorv32

# show the files built
echo "ULX3S Gateware:"
ls $WORKSPACE/litex-boards/litex_boards/targets/soc_basesoc_ulx3s/gateware -al

# if you want to modifiy the bios, see files in $WORKSPACE/litex/litex/soc/software/bios

echo "ULX3S BIOS:"
ls $WORKSPACE/litex-boards/litex_boards/targets/soc_basesoc_ulx3s/software/bios -al

# put the soft CPU on the ULX3S
cd "$WORKSPACE"/litex-boards/litex_boards/targets/soc_basesoc_ulx3s/gateware
$WORKSPACE/ulx3s-examples/bin/ujprog.exe top.bit

# helpful notes from @GregDavill: (see https://twitter.com/gojimmypi/status/1241485830356496384?s=20)
#
# The LiteX bios is what you're seeing running. 
#
# By default, LiteX builds this to execute from address 0x00000000. This is an address space 
# inside the FPGA, using blockram. Litex embeds the code inside so it's baked into the bit-stream.
#
# uart_sync() just waits until internal uart FIFOs are cleared. (Which ensures that printf data 
# has been sent to the PC...) printf also relies on interrupts, so once you've disable interrupts 
# printf no longer works.
# 
# The bios exists to initialise things like SDRAM, which you can see it doing here. It then tries 
# to load a USER program from SD/FLASH/Serial/Ethernet.

cd "$WORKSPACE"/litex-boards/litex_boards/targets/soc_basesoc_ulx3s/software/bios
litex_term --serial-boot --kernel bios.bin /dev/ttyS15

# press enter to confirm LiteX prompt, then type "reboot" (without quotes, then enter )

