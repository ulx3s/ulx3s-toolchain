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
# 
# see https://docs.espressif.com/projects/esp-idf/en/latest/get-started/index.html#get-started-get-esp-idf
#"***************************************************************************************************"

# the old idf needed these:
sudo apt-get install libncurses-dev gawk gperf grep gettext python python-dev \
     automake bison flex texinfo help2man libtool libtool-bin make --assume-yes   2>&1 | tee -a "$THIS_LOG"


# the new idf needs theses:
sudo apt-get install git wget flex bison gperf python python-pip python-setuptools \
     make ninja-build ccache libffi-dev libssl-dev                 --assume-yes   2>&1 | tee -a "$THIS_LOG"

sudo apt-get install python3 python3-pip python3-setuptools        --assume-yes   2>&1 | tee -a "$THIS_LOG"

# see https://github.com/ulx3s/ulx3s-toolchain/issues/5
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 10

#if [ "$(lsb_release --release)" == "Release:        20.04" ]; then
#  alias pip="pip3"
#else
#  sudo apt-get install python-pip                                    --assume-yes   2>&1 | tee -a "$THIS_LOG"
#fi

#  ensure our idf home diredtory exists
mkdir -p ~/esp
cd ~/esp

#"***************************************************************************************************"
# ESP32 toolchain installed to ~/esp
#"***************************************************************************************************"

echo "***************************************************************************************************"
echo " ESP32 crosstool-NG. Saving log to $THIS_LOG"
echo " see https://docs.espressif.com/projects/esp-idf/en/latest/get-started/linux-setup-scratch.html#compile-the-toolchain-from-source"
echo "***************************************************************************************************"
if [ ! -d ~/esp/crosstool-NG ]; then
  # Download crosstool-NG and build it:
  git clone https://github.com/espressif/crosstool-NG.git
  $SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"
  cd crosstool-NG
else
  cd crosstool-NG
  git fetch                                                       2>&1 | tee -a "$THIS_LOG"
  git pull                                                        2>&1 | tee -a "$THIS_LOG"
  $SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"
fi

echo ""                                                           2>&1 | tee -a "$THIS_LOG"
echo "checking out crosstool-NG esp-2019r2 (disabled!)"           2>&1 | tee -a "$THIS_LOG"
echo ""                                                           2>&1 | tee -a "$THIS_LOG"
#git checkout esp-2019r2                                          2>&1 | tee -a "$THIS_LOG"
git submodule update --init                                       2>&1 | tee -a "$THIS_LOG"
$SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"

echo ""                                                           2>&1 | tee -a "$THIS_LOG"
echo "ESP32 bootstrap and configure... "                          2>&1 | tee -a "$THIS_LOG"
echo ""                                                           2>&1 | tee -a "$THIS_LOG"
./bootstrap && ./configure --enable-local && make                 2>&1 | tee -a "$THIS_LOG"

# Build the toolchain:
echo Ready to build ESP32 toolchain... $(pwd)                     2>&1 | tee -a "$THIS_LOG"

./ct-ng xtensa-esp32-elf                                          2>&1 | tee -a "$THIS_LOG"
$SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"

./ct-ng build                                                     2>&1 | tee -a "$THIS_LOG"
$SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"

chmod -R u+w builds/xtensa-esp32-elf

cd $SAVED_CURRENT_PATH

#"***************************************************************************************************"
#
#"***************************************************************************************************"
cd ~/esp

echo "***************************************************************************************************"
echo " ESP32 esp-idf. Saving log to $THIS_LOG"
echo "***************************************************************************************************"
if [ ! -d ~/esp/esp-idf ]; then
  git clone --recursive https://github.com/espressif/esp-idf.git 2>&1 | tee -a "$THIS_LOG"
  cd ~/esp/esp-idf
else
  cd ~/esp/esp-idf
  git fetch                                                       2>&1 | tee -a "$THIS_LOG"
  git pull                                                        2>&1 | tee -a "$THIS_LOG"
  $SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"
fi

./install.sh                                             
$SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"


# needed in ~/.bashrc
cd ~/esp/esp-idf/
. ./export.sh                                                    2>&1 | tee -a "$THIS_LOG"

echo "Completed $0 "                                                  | tee -a "$THIS_LOG"
