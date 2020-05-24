#!/bin/bash
#"***************************************************************************************************"
#  ensure all the scripts here are executable
#"***************************************************************************************************"

echo "setting permissions"
pwd
chmod +x install_set_permissions.sh
./install_set_permissions.sh

#"***************************************************************************************************"
#  common initialization
#"***************************************************************************************************"
# perform some version control checks on this file
./gitcheck.sh $0

# initialize some environment variables and perform some sanity checks
. ./init.sh

# we don't want tee to capture exit codes
set -o pipefail

cd "$WORKSPACE"
#"***************************************************************************************************"
#  check for minimum system resources needed (typically 40GB new Ubuntu VM with 5GB RAM)
#"***************************************************************************************************"
if [ $(free | grep Mem | awk '{ print $2 }') -lt "$MIN_ULX3S_MEMORY" ]; then
  echo ""
  echo "System memory found:"
  free
  echo ""
  read -p "Warning: At least $MIN_ULX3S_MEMORY bytes of memory is needed. Press a key to continue"
fi

if [ $(df $PWD | awk '/[0-9]%/{print $(NF-2)}' ) -lt "$MIN_ULX3S_DISK" ]; then
  echo ""
  echo "Disk space found in $PWD"
  df $PWD
  echo ""
  read -p "Warning: At least $MIN_ULX3S_DISK bytes of free disk space is needed. Press a key to continue"
fi

echo "Install all ULX3S toolchains. Edit parameters in init.sh"
echo ""
echo "logs saved to $LOG_DIRECTORY"
echo ""
echo ""
read -p "Press enter to continue, or Ctrl-C to abort."

cd $SAVED_CURRENT_PATH

# check to see if we can reach repo.or.cz now, rather than pause with error later
echo ""
echo "check cz!"
echo ""
./check_cz.sh
if [ "$?" == "0" ]; then
  export THIS_SKIP_CZ="false"
else
  export THIS_SKIP_CZ="true"
fi

./install_openocd-esp32.sh

./install_openocd.sh
