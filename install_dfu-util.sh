#!/bin/bash
#"***************************************************************************************************"
#  common initialization
#"***************************************************************************************************"

# select master or some GitHub hash version, and whether or not to force a clean
THIS_CHECKOUT=master
THIS_CLEAN=true

# perform some version control checks on this file
./gitcheck.sh $0

# initialize some environment variables and perform some sanity checks (optional 1 keyowrd)
. ./init.sh

# we don't want tee to capture exit codes
set -o pipefail

#"***************************************************************************************************"
# install the dfu-util form from ulx3s. 
#
# normally installed with:
#
#   apt-get install dfutil
#
# this code is here if you want to dig futher
#"***************************************************************************************************"
echo "***************************************************************************************************"
echo " dfu-util. Saving log to $THIS_LOG"
echo "***************************************************************************************************"

# Call the common github checkout:

pushd .
cd "$WORKSPACE"

$SAVED_CURRENT_PATH/fetch_github.sh https://github.com/ulx3s/dfu-util.git dfu-util $THIS_CHECKOUT  2>&1 | tee -a "$THIS_LOG"
$SAVED_CURRENT_PATH/check_for_error.sh                                                               $?          "$THIS_LOG"

cd "$WORKSPACE"/dfu-util

# See INSTALL file for building

# we'll install the apt-get version for now...
dfu-util --version > /dev/null 2>&1
if [ "$?" != "0" ]; then
  if [ "$APTGET" == 1 ]; then
    echo "installing dfu-util ..."
    sudo apt-get install dfu-util --assume-yes                      2>&1 | tee -a "$THIS_LOG"
  fi
else
  echo "Skipping install of dfu-util. Already installed."           2>&1 | tee -a "$THIS_LOG"
fi
echo ""                                                             2>&1 | tee -a "$THIS_LOG"

dfu-util --version                                                  2>&1 | tee -a "$THIS_LOG"
$SAVED_CURRENT_PATH/check_for_error.sh                                $?          "$THIS_LOG"

# Generate build system files (requires autoconf from autotools)
# ./autogen.sh

# Generate makefiles
# ./configure

# Build executables
# make

# Install executables and manual pages (optional)
# sudo make install

popd
echo "Completed $0 "                                                     | tee -a "$THIS_LOG"
echo "----------------------------------"
