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
# 
# see https://docs.espressif.com/projects/esp-idf/en/latest/get-started/index.html#get-started-get-esp-idf
#"***************************************************************************************************"

sudo apt-get install gawk gperf grep gettext python python-dev automake bison flex texinfo help2man libtool libtool-bin make
mkdir -p ~/esp
cd ~/esp

#"***************************************************************************************************"
#
#"***************************************************************************************************"

echo "***************************************************************************************************"
echo " ESP32 crosstool-NG. Saving log to $THIS_LOG"
echo "***************************************************************************************************"
if [ ! -d ~/esp/crosstool-NG ]; then
  # Download crosstool-NG and build it:
  git clone https://github.com/espressif/crosstool-NG.git
  cd crosstool-NG
else
  cd crosstool-NG
  git fetch                                                       2>&1 | tee -a "$THIS_LOG"
  git pull                                                        2>&1 | tee -a "$THIS_LOG"
  $SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"
fi

echo ""
echo "checking out crosstool-NG esp-2019r2"
echo ""
git checkout esp-2019r2
git submodule update --init
./bootstrap && ./configure --enable-local && make

# Build the toolchain:
./ct-ng xtensa-esp32-elf
./ct-ng build
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
. $HOME/esp/esp-idf/export.sh

echo "Completed $0 "                                                  | tee -a "$THIS_LOG"
