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

if [ "$APTGET" == 1 ]; then
  #"***************************************************************************************************"
  # Install all system dependencies and updates
  #"***************************************************************************************************"
  echo "***************************************************************************************************"
  echo "update/upgrade current system. Saving log to $THIS_LOG"
  echo "***************************************************************************************************"
  sudo apt-get update --assume-yes        2>&1 | tee -a "$THIS_LOG"
  ./check_for_error.sh                      $?          "$THIS_LOG"

  sudo apt-get upgrade --assume-yes       2>&1 | tee -a "$THIS_LOG"
  ./check_for_error.sh                      $?          "$THIS_LOG"

  echo "***************************************************************************************************"
  echo "git install and config. Saving log to $THIS_LOG"
  echo "***************************************************************************************************"
  # These git .insteadOf options may not be needed if your firewall does not blocks the git ports, 
  # but we set anyhow. 
  #
  # it is unlikely to cause harm for these repositories, unless for some reason your firewall is blocking HTTPS
  sudo apt-get install git --assume-yes   2>&1 | tee -a "$THIS_LOG"
  ./check_for_error.sh                      $?          "$THIS_LOG"

  echo "***************************************************************************************************"
  echo " install x11 dependencies (only needed for WSL?)"
  echo "***************************************************************************************************"
  sudo apt install dbus-x11 --assume-yes
  ./check_for_error.sh                      $?           "$THIS_LOG"

  echo "***************************************************************************************************"
  echo "install icestorm dependencies. Saving log to $THIS_LOG"
  echo "***************************************************************************************************"
  # this next install needs a bit of disk space:
  #   0 upgraded, 205 newly installed, 0 to remove and 3 not upgraded.
  #   Need to get 130 MB of archives.
  #   After this operation, 652 MB of additional disk space will be used.
  #
  sudo apt-get install build-essential clang bison flex libreadline-dev \
            gawk tcl-dev libffi-dev git mercurial graphviz   \
            xdot pkg-config libftdi-dev --assume-yes 2>&1 | tee -a "$THIS_LOG"
  ./check_for_error.sh                                 $?          "$THIS_LOG"

  echo "***************************************************************************************************"
  echo "install Python and dependencies. Saving log to $THIS_LOG"
  echo "***************************************************************************************************"
  sudo apt-get install python python3  --assume-yes  2>&1 | tee -a "$THIS_LOG"
  ./check_for_error.sh                                 $?          "$THIS_LOG"

  sudo apt-get install python3-pip --assume-yes      2>&1 | tee -a "$THIS_LOG"
  ./check_for_error.sh                                 $?          "$THIS_LOG"

  pip3 install databases                             2>&1 | tee -a "$THIS_LOG"

  echo "***************************************************************************************************"
  echo "install apio. Saving log to $THIS_LOG"
  echo "***************************************************************************************************"
  pip3 install -U apio                 2>&1 | tee -a "$THIS_LOG"
  ./check_for_error.sh                   $?          "$THIS_LOG"

  echo "***************************************************************************************************"
  echo "install nextpnr dependencies. Saving log to $THIS_LOG"
  echo "***************************************************************************************************"
  # this next line is about another half gig of files!
  #   0 upgraded, 249 newly installed, 0 to remove and 3 not upgraded.
  #   Need to get 132 MB of archives.
  #   After this operation, 623 MB of additional disk space will be used.
  #
  sudo apt-get install libboost-all-dev python3-dev qt5-default \
            clang-format libeigen3-dev --assume-yes 2>&1 | tee -a "$THIS_LOG"
  ./check_for_error.sh                      $?                    "$THIS_LOG"

  sudo apt-get install cmake --assume-yes 2>&1 | tee -a           "$THIS_LOG"
  ./check_for_error.sh                      $?                    "$THIS_LOG"

  echo "***************************************************************************************************"
  echo "install RISCV system dependencies. Saving log to $THIS_LOG"
  echo "***************************************************************************************************"
  sudo apt-get install make        --assume-yes      2>&1 | tee -a "$THIS_LOG"
  sudo apt-get install make-guile  --assume-yes      2>&1 | tee -a "$THIS_LOG"
  sudo apt-get install libgmp3-dev --assume-yes      2>&1 | tee -a "$THIS_LOG"
  sudo apt-get install libmpfr-dev --assume-yes      2>&1 | tee -a "$THIS_LOG"
  sudo apt-get install libmpc-dev  --assume-yes      2>&1 | tee -a "$THIS_LOG"

  sudo apt-get install autoconf automake autotools-dev curl libmpc-dev \
            libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo \
            gperf libtool patchutils bc zlib1g-dev git libexpat1-dev --assume-yes  2>&1 | tee -a "$THIS_LOG"
  ./check_for_error.sh                   $?                                                      "$THIS_LOG"

  echo "***************************************************************************************************"
  echo "install iverilog. Saving log to $THIS_LOG"
  echo "***************************************************************************************************"
  sudo apt-get install iverilog --assume-yes  2>&1 | tee -a "$THIS_LOG"
  ./check_for_error.sh                          $?          "$THIS_LOG"

  echo "***************************************************************************************************"
  echo "install verilator. Saving log to $THIS_LOG"
  echo "***************************************************************************************************"
  # The following NEW packages will be installed:
  #  verilator
  # 0 upgraded, 1 newly installed, 0 to remove and 1 not upgraded.
  # Need to get 2878 kB of archives.
  # After this operation, 13.1 MB of additional disk space will be used.
  sudo apt-get install verilator  --assume-yes    2>&1 | tee -a "$THIS_LOG"
  ./check_for_error.sh                              $?          "$THIS_LOG"

  if grep -q Microsoft /proc/version; then
    echo "***************************************************************************************************"
    echo "WSL detected; Install x86_64-w64-mingw32-gcc; Saving log to $THIS_LOG"
    echo "***************************************************************************************************"
    sudo apt-get install mingw-w64   --assume-yes    2>&1 | tee -a "$THIS_LOG"
    ./check_for_error.sh                               $?          "$THIS_LOG"
  fi

  echo "***************************************************************************************************"
  echo "update/upgrade current system again. Saving log to $THIS_LOG"
  echo "***************************************************************************************************"
  sudo apt-get update --assume-yes        2>&1 | tee -a "$THIS_LOG"
  ./check_for_error.sh                      $?          "$THIS_LOG"

  sudo apt-get upgrade --assume-yes       2>&1 | tee -a "$THIS_LOG"
  ./check_for_error.sh                      $?          "$THIS_LOG"
fi

echo "Completed $0 " | tee -a "$THIS_LOG"
echo "----------------------------------"
