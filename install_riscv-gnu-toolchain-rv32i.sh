#!/bin/bash
#"***************************************************************************************************"
#  common initialization
#"***************************************************************************************************"
# perform some version control checks on this file
./gitcheck.sh $0

# initialize some environment variables and perform some sanity checks
. ./init.sh TEST

# we don't want tee to capture exit codes
set -o pipefail

#"***************************************************************************************************"
# 
#"***************************************************************************************************"
THIS_LOG=$LOG_DIRECTORY"/"$THIS_FILE_NAME"_riscv-gnu-toolchain-rv32i_"$LOG_SUFFIX".log"

# Ubuntu packages needed:
sudo apt-get install autoconf automake autotools-dev curl libmpc-dev \
        libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo \
    gperf libtool patchutils bc zlib1g-dev git libexpat1-dev                         2>&1 | tee -a "$THIS_LOG"

sudo mkdir /opt/riscv32i
sudo chown $USER /opt/riscv32i

# add to path
if [ "$(cat ~/.bashrc | grep  $THIS_RISCV_PATH)" == "" ]; then
  echo PATH=$PATH:$THIS_RISCV_PATH >> ~/.bashrc
  echo "~/.bashrc updated with this line:"
  echo PATH=$PATH:$THIS_RISCV_PATH
else
  echo "Found $THIS_RISCV_PATH in ~/.bashrc - path not changed."
fi

if [ "$(echo $PATH | grep  $THIS_RISCV_PATH)" == "" ]; then
  export PATH=$PATH:$THIS_RISCV_PATH
  echo "Updated current path: $PATH"
else
  echo "Path not updated. PATH=$PATH"
fi

echo "***************************************************************************************************"
echo " riscv-gnu-toolchain-rv32i. Saving log to $THIS_LOG"
echo "***************************************************************************************************"
if [ ! -d "$WORKSPACE"/riscv-gnu-toolchain-rv32i ]; then
   git clone https://github.com/riscv/riscv-gnu-toolchain riscv-gnu-toolchain-rv32i  2>&1 | tee -a "$THIS_LOG"
   git checkout 411d134
   cd riscv-gnu-toolchain-rv32i

   # if you see fatal: clone of 'git://  ... 
   # users sitting behind a firewall may need these:
   git config --global url.https://github.com/.insteadOf                  git://github.com/
   git config --global url.https://git.qemu.org/git/.insteadOf            git://git.qemu-project.org/
   git config --global url.https://anongit.freedesktop.org/git/.insteadOf git://anongit.freedesktop.org/
   git config --global url.https://github.com/riscv.insteadOf             git://github.com/riscv

   echo "This next step takes a long time. Be patient:"
   git submodule update --init --recursive
 else
   cd riscv-gnu-toolchain-rv32i
   git fetch                                                                         2>&1 | tee -a "$THIS_LOG"
   git pull                                                                          2>&1 | tee -a "$THIS_LOG"
   $SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"
   git submodule update --recursive                                                  2>&1 | tee -a "$THIS_LOG"
   git checkout 411d134                                                              2>&1 | tee -a "$THIS_LOG"
fi

# after we have new (or fresh) files, build
mkdir -p build;                                                                     2>&1 | tee -a "$THIS_LOG"
cd build

../configure --with-arch=rv32i --prefix=/opt/riscv32i                               2>&1 | tee -a "$THIS_LOG"
$SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"

make -j$(nproc)                                                                     2>&1 | tee -a "$THIS_LOG"
$SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"

echo "Completed $0 "                                                  | tee -a "$THIS_LOG"
 
