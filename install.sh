#!/bin/bash
export APTGET=0
export BAREBONES=0

for arg in "$@"
do
  if [ $arg == "barebones" ]; then
    export BAREBONES=1
  fi
  if [ $arg == "aptget" ]; then
    echo
    echo "  'sudo apt-get install' will be used to install needed packages."
    echo "  This only works on Ubuntu like Linux distro's!"
    echo
    export APTGET=1
  fi
done

if [ "$APTGET" != 0 ]; then
  # a fresh VM will sometimes not be able to install anything until after a fresh apt-get update
  echo "sudo apt-get update..."
  sudo apt-get update
fi

git --version
retVal=$?
if [ $retVal -ne 0 ]; then
  if [ "$APTGET" != 0 ]; then
    echo "installing git..."
    sudo apt-get install git --assume-yes
  fi
fi

# active toolchain component developers may wish to set this to something other than the default.
# avoid spaces in the WORKSPACE path.
if [ "$WORKSPACE" == "" ]; then
  if grep -q Microsoft /proc/version; then
    # Set default WSL location to C:\workspace
    export WORKSPACE=/mnt/c/ULX3S_workspace # put your WSL linux path here. Placed outside of WSL file system for easy refresh
  else
    # Set Ubuntu location to home directory ~/workspace
    export WORKSPACE=~/ULX3S_workspace  # put your pure linux workspace parent directory here.
  fi
else
  echo "Using WORKSPACE=$WORKSPACE"
fi
mkdir -p $WORKSPACE

pushd .
cd "$WORKSPACE"

# Why would we need a copy of the toolchain repo in our workspace which can be 
# different than the one we build this workspace from? It's very confusing when 
# debugging the install scripts.
if [ ! -d "$WORKSPACE"/ulx3s-toolchain ]; then
  echo "clone ulx3s-toolchain..."
  git clone https://github.com/ulx3s/ulx3s-toolchain.git
  cd ulx3s-toolchain
else
  echo "update ulx3s-toolchain..."
  cd ulx3s-toolchain
  git fetch
  git pull
fi

popd

# Why would we need a copy of the toolchain repo in our workspace which can be 
# different than the one we build this workspace from? It's very confusing when 
# debugging the install scripts.
if [ ! -d "$WORKSPACE"/ulx3s-toolchain ]; then
  echo ""
  echo "Error cloning with git. Check permissions of $WORKSPACE"
  echo ""
  if grep -q Microsoft /proc/version; then
    echo ""
    echo "If this is a fresh WSL install, try rebooting."
    echo ""
  fi

else

  # ulx3s-toolchain directory found
  chmod +x install_set_permissions.sh
  chmod +x dos2unix.sh

  ./install_set_permissions.sh > /dev/null 2>&1

  if [ "$BAREBONES" == 1 ]; then
    echo "Running ./install_barebones.sh"
    chmod +x ./install_barebones.sh > /dev/null 2>&1
    ./install_barebones.sh
  else 
    echo "Running ./install_all.sh"
    chmod +x ./install_all.sh > /dev/null 2>&1
    ./install_all.sh
  fi
  echo "Done!"
fi
