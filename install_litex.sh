#!/bin/bash
#"***************************************************************************************************"
# 
#"***************************************************************************************************"
./gitcheck.sh $0
SAVED_CURRENT_PATH=$(pwd)

#"***************************************************************************************************"
# check that we are not running as root
#"***************************************************************************************************"
ls /root > /dev/null 2>&1
EXIT_STAT=$?
if [ $EXIT_STAT -ne 0 ];then
  echo "Startup ulx3s toolchain. Security Context:" $(whoami) 2>&1 | tee -a  "$THIS_LOG"
else
  echo "Setup aborted. Do not run as root. Causes undesired install permissions. Enter sudo password as required during setup." 2>&1 | tee -a  "$THIS_LOG"
  exit 2
fi

if [ "$WORKSPACE" == "" ]; then
  if grep -q Microsoft /proc/version; then
    WORKSPACE=/mnt/c/workspace # put your WSL linux path here. Place outside of WSL file system for easy refresh
  else
    WORKSPACE=~/workspace  # put your pure linux workspace parent directory here. avoid spaces in path
  fi
fi

mkdir -p "$WORKSPACE"
mkdir -p "$WORKSPACE/install_logs"

LOG_SUFFIX=$(date +"%Y%m%d_%H%M%S")

# strip any path from $0 to get just the file name of this script, stripping any CR, LF, Tabs
THIS_FILE_NAME=$(basename $0 .sh | tr --delete '\t\r\n' )

LOG_DIRECTORY="$WORKSPACE/install_logs"

cd "$WORKSPACE"
echo ""
echo "Installing to $(pwd)"
#"***************************************************************************************************"
# 
#"***************************************************************************************************"
THIS_LOG=$LOG_DIRECTORY"/"$THIS_FILE_NAME"_litex_"$LOG_SUFFIX".log"

# LiteX system requirements (also requires riscv32-unknown-elf-gcc)
sudo apt install build-essential device-tree-compiler wget git python3-setuptools --assume-yes 2>&1 | tee -a "$THIS_LOG"

# ensure we have the RISC-V compiler isntalled
/opt/riscv32i/bin/riscv32-unknown-elf-gcc --version                               2>&1 | tee -a "$THIS_LOG"
$SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"

if [ "$?" != "0" ]; then
  echo    "Error /opt/riscv32i/bin/riscv32-unknown-elf-gcc not found"
  read -p "Press enter to continue, or Ctrl-C to abort."
fi

# $ wget https://raw.githubusercontent.com/enjoy-digital/litex/master/litex_setup.py
# $ chmod +x litex_setup.py
# $ ./litex_setup.py init install --user (--user to install to user directory)

wget https://raw.githubusercontent.com/enjoy-digital/litex/master/litex_setup.py  2>&1 | tee -a "$THIS_LOG"
chmod +x litex_setup.py                                                           2>&1 | tee -a "$THIS_LOG"

sudo ./litex_setup.py init                                                        2>&1 | tee -a "$THIS_LOG"
$SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"

sudo ./litex_setup.py install                                                     2>&1 | tee -a "$THIS_LOG"
$SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"

# $ wget https://raw.githubusercontent.com/enjoy-digital/litex/master/litex_setup.py
# $ chmod +x litex_setup.py
# $ ./litex_setup.py init
# $ sudo ./litex_setup.py install

# TODO 
# ./litex_setup.py update

cd "$WORKSPACE"
THIS_LOG=$LOG_DIRECTORY"/"$THIS_FILE_NAME"_linux-on-litex-vexriscv_"$LOG_SUFFIX".log"
echo "***************************************************************************************************"
echo " linux-on-litex-vexriscv. Saving log to $THIS_LOG"
echo "***************************************************************************************************"
if [ ! -d "$WORKSPACE"/linux-on-litex-vexriscv ]; then
  git clone --recursive https://github.com/enjoy-digital/linux-on-litex-vexriscv  2>&1 | tee -a "$THIS_LOG"
  cd linux-on-litex-vexriscv
else
  cd linux-on-litex-vexriscv
  git fetch                                                                       2>&1 | tee -a "$THIS_LOG"
  git pull                                                                        2>&1 | tee -a "$THIS_LOG"
  $SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"
fi

./make.py --board ULX3S
$SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"

echo "Completed $0 "                                                  | tee -a "$THIS_LOG"
