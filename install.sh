#!/bin/bash

echo "installing git..."
sudo apt-get install git --assume-yes

mkdir -p ~/workspace
cd ~/workspace

git clone https://github.com/gojimmypi/ulx3s-toolchain.git
cd ulx3s-toolchain

echo "running ./install_all.sh"
chmod +x ./install_all.sh
./install_all.sh

echo "Done!"
