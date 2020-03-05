#!/bin/bash
# see https://docs.espressif.com/projects/esp-idf/en/latest/get-started/index.html#get-started-get-esp-idf

sudo apt-get install gawk gperf grep gettext python python-dev automake bison flex texinfo help2man libtool libtool-bin make
mkdir -p ~/esp
cd ~/esp

# Download crosstool-NG and build it:
git clone https://github.com/espressif/crosstool-NG.git
cd crosstool-NG
git checkout esp-2019r2
git submodule update --init
./bootstrap && ./configure --enable-local && make

# Build the toolchain:
./ct-ng xtensa-esp32-elf
./ct-ng build
chmod -R u+w builds/xtensa-esp32-elf

# fetch the IDF
cd ~/esp
git clone --recursive https://github.com/espressif/esp-idf.git


# install
cd ~/esp/esp-idf
./install.sh

# needed in ~/.bashrc
. $HOME/esp/esp-idf/export.sh
