#!/bin/bash
#"***************************************************************************************************"
#  common initialization
#"***************************************************************************************************"

# select master or some GitHub hash version, and whether or not to force a clean
THIS_CHECKOUT=master
THIS_CLEAN=true

# perform some version control checks on this file
./gitcheck.sh $0

# initialize some environment variables and perform some sanity checks
. ./init.sh

# we don't want tee to capture exit codes
set -o pipefail

#"***************************************************************************************************"
#  Install LiteX
#
#  see https://github.com/enjoy-digital/litex/ 
#"***************************************************************************************************"

if [ "$APTGET" == 1 ]; then
  # LiteX system requirements (also requires riscv32-unknown-elf-gcc)
  sudo apt-get install build-essential device-tree-compiler wget git python3-setuptools --assume-yes 2>&1 | tee -a "$THIS_LOG"

  # LiteX sim requirements
  sudo apt-get install libevent-dev libjson-c-dev verilator --assume-yes                             2>&1 | tee -a "$THIS_LOG"
fi

# ensure we have the RISC-V compiler isntalled
/opt/riscv32i/bin/riscv32-unknown-elf-gcc --version                                 2>&1 | tee -a "$THIS_LOG"
$SAVED_CURRENT_PATH/check_for_error.sh                                                $?          "$THIS_LOG"

if [ "$?" != "0" ]; then
  echo    "Error /opt/riscv32i/bin/riscv32-unknown-elf-gcc not found"
  read -p "Press enter to continue, or Ctrl-C to abort."
fi

pushd .
cd "$WORKSPACE"

# $ wget https://raw.githubusercontent.com/enjoy-digital/litex/master/litex_setup.py
# $ chmod +x litex_setup.py
# $ ./litex_setup.py init install --user (--user to install to user directory)

if [ ! -f "$WORKSPACE"/litex_setup.py ]; then
  wget https://raw.githubusercontent.com/enjoy-digital/litex/master/litex_setup.py  2>&1 | tee -a "$THIS_LOG"
  chmod +x litex_setup.py                                                           2>&1 | tee -a "$THIS_LOG"

  ./litex_setup.py init --user                                                      2>&1 | tee -a "$THIS_LOG"
  $SAVED_CURRENT_PATH/check_for_error.sh                                              $?          "$THIS_LOG"

  ./litex_setup.py install --user                                                   2>&1 | tee -a "$THIS_LOG"
  $SAVED_CURRENT_PATH/check_for_error.sh                                              $?          "$THIS_LOG"
else
  mv litex_setup.py litex_setup.py.old

  if [ -f litex_setup.py  ]; then
    rm  litex_setup.py
  fi
  wget https://raw.githubusercontent.com/enjoy-digital/litex/master/litex_setup.py  2>&1 | tee -a "$THIS_LOG"
  chmod +x litex_setup.py                                                           2>&1 | tee -a "$THIS_LOG"

  ./litex_setup.py init --user 

  ./litex_setup.py update --user                                                    2>&1 | tee -a "$THIS_LOG"
  $SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"
fi

# $ wget https://raw.githubusercontent.com/enjoy-digital/litex/master/litex_setup.py
# $ chmod +x litex_setup.py
# $ ./litex_setup.py init
# $ sudo ./litex_setup.py install

# TODO 
# ./litex_setup.py update

cd "$WORKSPACE"THIS_LOG=$LOG_DIRECTORY"/"$THIS_FILE_NAME"_linux-on-litex-vexriscv_"$LOG_SUFFIX".log"

echo "***************************************************************************************************"
echo " linux-on-litex-vexriscv. Saving log to $THIS_LOG"
echo "***************************************************************************************************"

# Call the common github checkout:

$SAVED_CURRENT_PATH/fetch_github.sh https://github.com/enjoy-digital/linux-on-litex-vexriscv linux-on-litex-vexriscv $THIS_CHECKOUT  2>&1 | tee -a "$THIS_LOG"
$SAVED_CURRENT_PATH/check_for_error.sh                                                                                                 $?          "$THIS_LOG"

cd "$WORKSPACE"/linux-on-litex-vexriscv

sudo chown $USER $WORKSPACE/litex/litex/boards/targets/
sudo chown $USER $WORKSPACE/litex-boards/litex_boards/targets

popd
. $SAVED_CURRENT_PATH/set_riscv_path.sh
echo "Completed $0 "                                                   | tee -a "$THIS_LOG"
echo "----------------------------------"
