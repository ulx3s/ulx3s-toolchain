#!/bin/bash
#
#
#  ujprog is deprecated; see fujprog
#
#
#"***************************************************************************************************"
#  common initialization
#"***************************************************************************************************"
# perform some version control checks on this file
./gitcheck.sh $0

# initialize some environment variables and perform some sanity checks
. ./init.sh ujprog

# we don't want tee to capture exit codes
set -o pipefail

#"***************************************************************************************************"
# Install ujprog from f32c (used to upload binaries to ULX3S)
#"***************************************************************************************************"
echo "***************************************************************************************************"
echo " ujprog. Saving log to $THIS_LOG"
echo "***************************************************************************************************"
# see https://github.com/f32c/tools/tree/master/ujprog
# NOTE: Although this successfully compiles, it does not seem to work in WSL (no USB device support, use EXE instead)

pushd .
cd "$WORKSPACE"

if [ ! -d "$WORKSPACE"/f32c_tools ]; then
  git clone https://github.com/f32c/tools.git f32c_tools         2>&1 | tee -a "$THIS_LOG"
  $SAVED_CURRENT_PATH/check_for_error.sh                           $?          "$THIS_LOG"
  cd "$WORKSPACE"/f32c_tools/ujprog
else
  cd "$WORKSPACE"/f32c_tools
  git fetch                                                      2>&1 | tee -a "$THIS_LOG"
  git pull                                                       2>&1 | tee -a "$THIS_LOG"
  $SAVED_CURRENT_PATH/check_for_error.sh                           $?          "$THIS_LOG"

  cd "$WORKSPACE"/ujprog

  # make clean                                                     2>&1 | tee -a "$THIS_LOG"
  $SAVED_CURRENT_PATH/check_for_error.sh                           $?          "$THIS_LOG"
fi

# There's no point to making the linux version of ujprog in WSL, as native USB devices are not supported.
# but we can compile the Windows version, amd actually call it from WSL (call from /mnt/c... not ~/...)
if grep -q Microsoft /proc/version; then
  echo "***************************************************************************************************"
  echo " ming32_64. Saving log to $THIS_LOG"
  echo "***************************************************************************************************"

  make -f Makefile.ming32_64                                     2>&1 | tee -a "$THIS_LOG"
  $SAVED_CURRENT_PATH/check_for_error.sh                           $?          "$THIS_LOG"

  # sudo make -f Makefile.ming32_64 install                        2>&1 | tee -a "$THIS_LOG"
  $SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"
else
  make -f Makefile.linux                                         2>&1 | tee -a "$THIS_LOG"
  $SAVED_CURRENT_PATH/check_for_error.sh                           $?          "$THIS_LOG"

  sudo make -f Makefile.linux install                            2>&1 | tee -a "$THIS_LOG"
  $SAVED_CURRENT_PATH/check_for_error.sh                           $?          "$THIS_LOG"
   
  # The default install directory for ujprog is /usr/local/bin/ujprog however the rxrbln Makefile 
  # expects it to be /usr/src/f32c-ujprog/ujprog/ujprog so we'll just create a quick symlink
  sudo mkdir -p /usr/src/f32c-ujprog/ujprog/
  sudo ln -s /usr/local/bin/ujprog /usr/src/f32c-ujprog/ujprog/ujprog
  $SAVED_CURRENT_PATH/check_for_error.sh                           $?          "$THIS_LOG"
fi

popd
echo "Completed $0 "                                                  | tee -a "$THIS_LOG"
echo "----------------------------------"
