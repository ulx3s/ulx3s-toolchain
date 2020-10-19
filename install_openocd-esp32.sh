#!/bin/bash

if [ "$THIS_SKIP_CZ" == "" ]; then 
  ./check_cz.sh
  if [ "$?" == "0" ]; then
    export THIS_SKIP_CZ="false"
  else
    export THIS_SKIP_CZ="true"
  fi
  echo "$0 Set THIS_SKIP_CZ=$THIS_SKIP_CZ"
else
  echo "$0 Found THIS_SKIP_CZ=$THIS_SKIP_CZ"
fi


if [ "$THIS_SKIP_CZ" == "true" ]; then
  echo ""
  echo "Skipping install_openocd since it needs access to https://repo.or.cz; THIS_SKIP_CZ=$THIS_SKIP_CZ"
  echo ""
  exit 0
fi

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
# Install OpenOCD for the ESP32
#"***************************************************************************************************"

echo "***************************************************************************************************" | tee -a "$THIS_LOG"
echo " openocd-esp32. Saving log to $THIS_LOG"                                                             | tee -a "$THIS_LOG"
echo "***************************************************************************************************" | tee -a "$THIS_LOG"

# Call the common github checkout:

pushd .
cd "$WORKSPACE"

$SAVED_CURRENT_PATH/fetch_github.sh https://github.com/espressif/openocd-esp32 openocd-esp32 $THIS_CHECKOUT  2>&1 | tee -a "$THIS_LOG"
$SAVED_CURRENT_PATH/check_for_error.sh                                                                         $?          "$THIS_LOG"

cd "$WORKSPACE"/openocd-esp32

# TODO is this installed to same location as regular openocd?

echo ""                            | tee -a "$THIS_LOG"
echo ""                            | tee -a "$THIS_LOG"
./bootstrap                   2>&1 | tee -a "$THIS_LOG"

echo ""                            | tee -a "$THIS_LOG"
echo ""                            | tee -a "$THIS_LOG"
./configure                   2>&1 | tee -a "$THIS_LOG"

echo ""                            | tee -a "$THIS_LOG"
echo "make"                        | tee -a "$THIS_LOG"
make -j$(nproc)               2>&1 | tee -a "$THIS_LOG"

echo ""                            | tee -a "$THIS_LOG"
echo "sudo make install"           | tee -a "$THIS_LOG"
sudo make install             2>&1 | tee -a "$THIS_LOG"

popd
echo "Completed $0 "               | tee -a "$THIS_LOG"
echo "----------------------------------"
