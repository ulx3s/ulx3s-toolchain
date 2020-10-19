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
# Install the picorv32 from rxrbln that has some interesting ULX3S work
#"***************************************************************************************************"

echo "***************************************************************************************************"
echo "rxrbln's fork of picorv32 for the ULX3S. Saving log to $THIS_LOG"
echo "***************************************************************************************************"

pushd .
cd "$WORKSPACE"

if [ ! -d "$WORKSPACE"/rxrbln-picorv32 ]; then
  git clone --recursive https://github.com/rxrbln/picorv32 rxrbln-picorv32  2>&1 | tee -a "$THIS_LOG"
  $SAVED_CURRENT_PATH/check_for_error.sh                                      $?          "$THIS_LOG"
  cd rxrbln-picorv32
else
  cd rxrbln-picorv32
  git fetch                                                       2>&1 | tee -a "$THIS_LOG"
  git pull                                                        2>&1 | tee -a "$THIS_LOG"
  $SAVED_CURRENT_PATH/check_for_error.sh                            $?          "$THIS_LOG"
fi

make -j$(nproc)                                                   2>&1 | tee -a "$THIS_LOG"
$SAVED_CURRENT_PATH/check_for_error.sh                              $?          "$THIS_LOG"

popd
echo "Completed $0 "                                                   | tee -a "$THIS_LOG"
echo "----------------------------------"
