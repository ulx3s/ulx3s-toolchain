#!/bin/bash
#"***************************************************************************************************"
#  common initialization: set RISCV path both for current shell, as well in ~/.bashrc as needed
#"***************************************************************************************************"
# perform some version control checks on this file
./gitcheck.sh $0

# initialize some environment variables and perform some sanity checks
. ./init.sh

# we don't want tee to capture exit codes
set -o pipefail

# add to path
if [ "$(cat ~/.bashrc | grep  $THIS_RISCV_PATH)" == "" ]; then
  echo 'export PATH=$PATH:'$THIS_RISCV_PATH >> ~/.bashrc
  echo "~/.bashrc updated with this line:"
  echo 'PATH=$PATH:'$THIS_RISCV_PATH
else
  echo "Found $THIS_RISCV_PATH in ~/.bashrc - path not changed."
fi

if [ "$(echo $PATH | grep  $THIS_RISCV_PATH)" == "" ]; then
  export PATH=$PATH:$THIS_RISCV_PATH
  echo "Updated current path: $PATH"
else
  echo "Path already correct. PATH=$PATH"
fi
