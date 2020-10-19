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
# Install riscv-gnu-toolchain-rv32i
#"***************************************************************************************************"
THIS_LOG=$LOG_DIRECTORY"/"$THIS_FILE_NAME"_riscv-gnu-toolchain-rv32i_"$LOG_SUFFIX".log"

if [ "$APTGET" == 1 ]; then
  # Needed Ubuntu packages:
  sudo apt-get install autoconf automake autotools-dev curl libmpc-dev \
          libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo \
          gperf libtool patchutils bc zlib1g-dev git libexpat1-dev  --assume-yes    2>&1 | tee -a "$THIS_LOG"
fi

sudo mkdir -p /opt/riscv32i
sudo chown $USER /opt/riscv32i

# # setup the path, even though there may be nothing in it yet
# cd ulx3s-toolchain
. ./set_riscv_path.sh

pushd .
cd "$WORKSPACE"

echo "***************************************************************************************************"
echo " riscv-gnu-toolchain-rv32i. Saving log to $THIS_LOG"
echo "***************************************************************************************************"

# users sitting behind a firewall may need these:
git config --global url.https://github.com/.insteadOf                  git://github.com/
git config --global url.https://git.qemu.org/git/.insteadOf            git://git.qemu-project.org/
git config --global url.https://anongit.freedesktop.org/git/.insteadOf git://anongit.freedesktop.org/
git config --global url.https://github.com/riscv.insteadOf             git://github.com/riscv

if [ ! -d "$WORKSPACE"/riscv-gnu-toolchain-rv32i ]; then
  git clone https://github.com/riscv/riscv-gnu-toolchain riscv-gnu-toolchain-rv32i  2>&1 | tee -a "$THIS_LOG"
  $SAVED_CURRENT_PATH/check_for_error.sh                                              $?          "$THIS_LOG"

  cd "$WORKSPACE"/riscv-gnu-toolchain-rv32i
  git checkout 411d134

  echo "This next step takes a long time. Be patient:"
  git submodule update --init --recursive
  $SAVED_CURRENT_PATH/check_for_error.sh                                              $?          "$THIS_LOG"
else
   cd "$WORKSPACE"/riscv-gnu-toolchain-rv32i
   git fetch                                                                        2>&1 | tee -a "$THIS_LOG"

   # we are in a detached head at 411d134 so cannot pull
   # git pull                                                                        2>&1 | tee -a "$THIS_LOG"
   # $SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"
   # git checkout 411d134

   git submodule update --recursive                                                 2>&1 | tee -a "$THIS_LOG"
fi

# after we have new (or fresh) files, build
mkdir -p "$WORKSPACE"/riscv-gnu-toolchain-rv32i/build;                              2>&1 | tee -a "$THIS_LOG"
$SAVED_CURRENT_PATH/check_for_error.sh                                                $?          "$THIS_LOG"

cd "$WORKSPACE"/riscv-gnu-toolchain-rv32i/build

../configure --with-arch=rv32i --prefix=/opt/riscv32i                               2>&1 | tee -a "$THIS_LOG"
$SAVED_CURRENT_PATH/check_for_error.sh                                                $?          "$THIS_LOG"

make -j$(nproc)                                                                     2>&1 | tee -a "$THIS_LOG"
$SAVED_CURRENT_PATH/check_for_error.sh                                                $?          "$THIS_LOG"

popd
echo "Completed $0 "                                                                     | tee -a "$THIS_LOG"
echo "----------------------------------"
