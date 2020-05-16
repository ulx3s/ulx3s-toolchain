#!/bin/bash
, export WORKSPACE=/mnt/c/workspace/test

git --version
retVal=$?
if [ $retVal -ne 0 ]; then
    echo "installing git..."
    sudo apt-get install git --assume-yes
fi

# active toolchain component developers may wish to set this to something other than the default.
# avoid spaces in the WORKSPACE path.
if [ "$WORKSPACE" == "" ]; then
  if grep -q Microsoft /proc/version; then
    # Set default WSL location to C:\workspace
    mkdir -p /mnt/c/workspace
    export WORKSPACE=/mnt/c/workspace # put your WSL linux path here. Placed outside of WSL file system for easy refresh
  else
    # Set Ubuntu location to home directory ~/workspace
    mkdir -p ~/workspace
    export WORKSPACE=~/workspace  # put your pure linux workspace parent directory here.
  fi
else
  echo "Using WORKSPACE=$WORKSPACE"
  mkdir -p $WORKSPACE
fi

cd "$WORKSPACE"
pwd


if [ ! -d "$WORKSPACE"/ulx3s-toolchain ]; then
  echo "clone ulx3s-toolchain..."
  git clone https://github.com/gojimmypi/ulx3s-toolchain.git       
  cd ulx3s-toolchain
else
  echo "update ulx3s-toolchain..."
  cd ulx3s-toolchain
  git fetch                                                     
  git pull                                                      
fi

if [ "$1" == "barebones" ]; then
  echo "Running ./install_barebones.sh"
  chmod +x ./install_barebones.sh
  ./install_barebones.sh

else 
  echo "Running ./install_all.sh"
  chmod +x ./install_all.sh
  ./install_all.sh

  echo "Done!"
fi