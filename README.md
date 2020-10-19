# ulx3s-toolchain

ULX3S FPGA, RISC-V, ESP32 toolchain installer scripts. 

This toolchain builder focuses on the ULX3S and Ubuntu (including WSL), but can easily be adapted to other platforms and target FPGA chips.

The [ULX3S](https://radiona.org/ulx3s/) is now at [Crowd Supply](https://www.crowdsupply.com/radiona/ulx3s)!

Run `install_all.sh` to install everything, or see each individual `install_[feature].sh` file.

There's also a `./install.sh barebones` to install only the essentials for FPGA: verilator/yosys/nextpnr/fujprog. (useful for Visual Studio)

For a quick start without compiling everything yourself, kost has some precompiled [binary releases](https://github.com/alpin3/ulx3s/releases).

For Multi-platform nightly builds of open source FPGA tools, check out [fpga-toolchain](https://github.com/open-tool-forge/fpga-toolchain).

## Introduction

This script automates and consolidates the many different toolchain scripts. (FPGA, ESP32, LiteX)

Installation logs are saved in `$WORKSPACE/install_logs/` with suffixes `YYYYMMSS_HHMMSS` such as `20200307_105326`

Installation will pause if an error is encountered.

For getting started, see the included [ulx3s-examples](https://github.com/ulx3s/ulx3s-examples), 
the [fpga-odysseus/tutorials](https://github.com/ulx3s/fpga-odysseus/tree/master/tutorials), 
emard's [ulx3s](https://github.com/emard/ulx3s) PCB 
and [ulx3s-misc](https://github.com/emard/ulx3s-misc) miscellaneous examples (advanced). 
The [ulx3s.github.io](https://ulx3s.github.io/) has even more resources. 

See [timvideos LiteX for Hardware Engineers](https://github.com/timvideos/litex-buildenv/wiki/LiteX-for-Hardware-Engineers)

## Requirements

Note that in a fresh Ubuntu VM, 36GB of disk space and 5GB (5,120 MB) of RAM is the minimum neccessary. 
for all components to install successfully.

see `init.sh` for setting parameters. Of particular interest (consider putting in `~/.bashrc` - edit for your respective device):

For Ubuntu
```
WORKSPACE=~/workspace
THIS_ULX3S_DEVICE=LFE5U-85F
ULX3S_COM=/dev/ttyS8

# for ESP32 IDF
cd ~/esp/esp-idf/
. ./export.sh

# the apt-get is now optional (needed for individual Ubuntu and WSL install files other than "all")
# the default it to not use apt-get, so we need to turn it on
export APTGET=1
```

For WSL:
```
WORKSPACE=/mnt/c/workspace
THIS_ULX3S_DEVICE=LFE5U-85F
ULX3S_COM=/dev/ttyS8

# for ESP32 IDF
cd ~/esp/esp-idf/
. ./export.sh

# the apt-get is now optional (needed for individual Ubuntu and WSL install files other than "all")
# the default it to not use apt-get, so we need to turn it on
export APTGET=1
```

Reminder: ~~WSL numbers are [n-1] (e.g. ttyS8 is COM9)~~ (edit: this appears to no longer be the case?)

The install is generally attention-free, although so ridiculously long that the `sudo` command will occasionally re-ask for a password.

Consider using `sudo visudo` to extend or disable the `sudo` timeout. 
See [this](https://apple.stackexchange.com/questions/10139/how-do-i-increase-sudo-password-remember-timeout).
Use with caution and common sense. It would probably be wise to remove this upon completion:

Add this line to disable sudo timeouts from asking for a password repeatedly during install:
```
Defaults    timestamp_timeout=-1
```

Note that `OpenOCD` installation fetches some code from `repo.or.cz` domain. 
Keep this in mind if your firewall or [dns blocker](https://pi-hole.net/) blocks some domains.

## Installation

### Quick Start, only the bare essentials:

```
cd ~
wget https://raw.githubusercontent.com/ulx3s/ulx3s-toolchain/master/install.sh
chmod +x install.sh
./install.sh barebones aptget
```


### Full Install

Install everything:

```
cd ~
wget https://raw.githubusercontent.com/ulx3s/ulx3s-toolchain/master/install.sh
chmod +x install.sh
./install.sh aptget
```
or

```
sudo apt-get install git --assume-yes
mkdir -p ~/workspace
cd ~/workspace
git clone https://github.com/ulx3s/ulx3s-toolchain.git
cd ulx3s-toolchain
chmod +x ./install.sh
./install.sh aptget
```

## ULX3S Binaries

Binaries specific to the ULX3S are generated during the full install.

See `./install_litex-ulx3s.sh`

## Results

The ESP32 toolchain is installed to `~/esp`. Everything else is installed to the directory in $WORKSPACE

See:

BIOS: `$WORKSPACE/linux-on-litex-vexriscv/build/ulx3s/software/bios` for:
`emulator.bin` and `bios.bin`


`$WORKSPACE/litex-boards/litex_boards/targets`

FPGA: `$WORKSPACE/litex-boards/litex_boards/targets/soc_basesoc_ulx3s/gateware`
`top.bit`

`$WORKSPACE/litex-boards/litex_boards/targets/soc_basesoc_ulx3s/software/bios`

## Programmming and Code Upload

Windows WSL Ubuntu
```
cd $WORKSPACE/litex-boards/litex_boards/targets/soc_basesoc_ulx3s/gateware

$WORKSPACE/ulx3s-examples/bin/ujprog.exe top.bit
```

Ubuntu
```
cd $WORKSPACE/litex-boards/litex_boards/targets/soc_basesoc_ulx3s/gateware

$WORKSPACE/ulx3s-examples/bin/ujprog top.bit
```

# Other tips

List ip interfaces:
```
ip link
```

Add an IP address for interface `ens33`:
```
sudo ip address add 192.168.100.100/24 dev ens33
```

Show IP address(s):
```
ip address
```

Find all the files and directories that contain the word ULX3S (case insensitive)

```
find / -xdev 2>/dev/null -iname "*ULX3S*"
```

if litex init and install was run with sudo, use this to fix re-running `./ulx3s.py` and `./make.py`
```
sudo chown $USER $WORKSPACE/litex-boards/litex_boards/targets
```

Find all files created after a given date/time in Powershell:
```
Get-ChildItem -Recurse | Where-Object { $_.LastWriteTime -ge "03/08/2020 4:25pm" }
```

