# ulx3s-toolchain
ULX3S FPGA, RISC-V, ESP32 toolchain installer scripts

run `install_all.sh` to install everything, or see each individual `install_[feature].sh` file.

Note that in a fresh Ubuntu VM, 30GB of disk space and 5GB of RAM is the minimum neccessary 
for all components to isntall successfully.

see `init.sh` for setting parameters.

to instal lfrom scratch:
```
sudo apt-get install git --assume-yes
mkdir -p ~/workspace
cd ~/workspace
git clone https://github.com/gojimmypi/ulx3s-toolchain.git
cd ulx3s-toolchain
chmod +x ./install_all.sh
./install_all.sh
```

