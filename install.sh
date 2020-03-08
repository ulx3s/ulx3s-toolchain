sudo apt-get install git --assume-yes
mkdir -p ~/workspace
cd ~/workspace
git clone https://github.com/gojimmypi/ulx3s-toolchain.git
cd ulx3s-toolchain
chmod +x ./install_all.sh
./install_all.sh
