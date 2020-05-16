#!/bin/bash
#"***************************************************************************************************"
# this is a RISCV toolchain script for reference only. See install_all.sh
#"***************************************************************************************************"
STARTING_PATH=$(pwd)

THIS_RISCV=riscv32i
THIS_RISCV_PATH=/opt/$THIS_RISCV/bin

WORKSPACE=~/workspace       # put your workspace parent directory here. avoid spaces in path
mkdir -p "$WORKSPACE"
mkdir -p "$WORKSPACE/install_logs"

# see https://unix.stackexchange.com/questions/14270/get-exit-status-of-process-thats-piped-to-another/73180#73180
# we don't want tee to capture exit codes
set -o pipefail

# convert entire list of params to single lower case string
params="$(tr [A-Z] [a-z] <<< "$@")"
# echo $params

LOG_SUFFIX=$(date +"%Y%m%d_%H%M%S")

# strip any path from $0 to get just the file name of this script, stripping any CR, LF, Tabs
THIS_FILE_NAME=$(basename $0 .sh | tr --delete '\t\r\n' )

LOG_DIRECTORY="$WORKSPACE/install_logs"

THIS_LOG=$LOG_DIRECTORY"/"$THIS_FILE_NAME"_riscv_"$LOG_SUFFIX".log"




sudo apt-get update --assume-yes      2>&1 | tee -a  "$THIS_LOG"
sudo apt-get upgrade --assume-yes     2>&1 | tee -a  "$THIS_LOG"
sudo apt-get install git --assume-yes 2>&1 | tee -a  "$THIS_LOG"



#"***************************************************************************************************"
# CheckForError() function
#
# example: CheckForError $? mylog.1.txt mylog2.txt
#
# functions are a common place to get weird script errors. typically carriage returns. use dos2unix
#
# for cmake internal recipe errors, see: https://cmake.org/cmake/help/v3.9/command/execute_process.html
#
# note tee captures error code: https://stackoverflow.com/questions/1221833/pipe-output-and-capture-exit-status-in-bash
#"***************************************************************************************************"
CheckForError() { # $1 expected to be error code via $?
	if [ "$1" != "0" ]; then
		if [ "$2" != "" ]; then
			echo "---------------------------"
			echo "Looking in $2 for errors..."
			echo "---------------------------"
			grep -v " --disable-werror " "$2" | grep -B2 -i error
		fi
		if [ "$3" != "" ]; then
			echo "---------------------------"
			echo "Looking in $3 for errors..."
			echo "---------------------------"
			grep -v " --disable-werror " "$3" | grep -B2 -i error
		fi
		if [ "$4" != "" ]; then
			echo "---------------------------"
			echo "Looking in $4 for errors..."
			echo "---------------------------"
			grep -v " --disable-werror " "$4" | grep -B2 -i error
		fi
		if [ "$5" != "" ]; then
			echo "---------------------------"
			echo "Looking in $5 for errors..."
			echo "---------------------------"
			grep -v " --disable-werror " "$5" | grep -B2 -i error
		fi
		read -p "Error detected. Try updating dependencies. Press enter to continue, or Ctrl-C to abort."
	else
		echo "Ok! Exit code = [$1] using params=$params" 
	fi
}

#"***************************************************************************************************"
# CheckForGitFileChange() bash function. Compare hash of local file to one on GitHub
# 
# example: check specific file:
#   CheckForGitFileChange ~/workspace/nextpnr/README.md
#
# example: check this bash file:
#   CheckForGitFileChange $0    
#
# see https://gist.github.com/gojimmypi/22b7d43ce69e9c828e97534ff0a1d27f
#
#"***************************************************************************************************"
CheckForGitFileChange() {
	SAVED_CURRENT_PATH=$(pwd)
	if [ ! -f "$1" ]; then
		echo "File not found: "$1
		return 1
	fi

	## in case we get called from some other directory, we need to know the entire path of this file
	## as git commands need to be run in the repository directory.
	GIT_REL_PATH=$(dirname $1 | tr --delete '\t\r\n') 
	GIT_FULL_PATH="$(cd "${GIT_REL_PATH}"; pwd)"
	GIT_FILE_NAME=$(basename $1 | tr --delete '\t\r\n' )
	echo "Checking"$GIT_FULL_PATH"/"$GIT_FILE_NAME

	cd $GIT_FULL_PATH

	# compares occur to local files only, so quietly fetch
	git fetch > /dev/null

	# we first need to get the latest commit hash
	# COMMIT_HASH=$(git show --format=%H --no-patch --no-abbrev-commit HEAD..origin/master | head -1)
    COMMIT_HASH=$(git show --format=%H --no-patch --no-abbrev-commit HEAD..origin/master)

	# view the file in the commit hash found and pipe to `git hash-object` to compute hash
	GIT_HASH=$(git show $COMMIT_HASH:$1 | git hash-object --stdin )

	# simple `git hash-object` to compute hash of the local file
	THIS_HASH=$(git hash-object $1)

	# some visual entertainment
	echo "COMMIT_HASH = $COMMIT_HASH"
	echo "GIT_HASH    = $GIT_HASH"
	echo "THIS_HASH   = $THIS_HASH"

	if [ "$THIS_HASH" == "$GIT_HASH" ]; then
		echo "Confirmed $1 is the most recent version found in GitHub."
	else 
		echo "Warning! This version of $1 does not match the most recent version in GitHub!"
		read -p "Press enter to continue, or Ctrl-C to abort. (manually push/pull recent file)"
	fi
	cd $SAVED_CURRENT_PATH
}

CheckForGitFileChange $0


if [[ "$1" == *"--rxrbln-picorv32"* ]] || [ "$1" == "" ]; then
    cd "$WORKSPACE"
    THIS_LOG=$LOG_DIRECTORY"/"$THIS_FILE_NAME"_rxrbln-picorv32_"$LOG_SUFFIX".log"

    echo "***************************************************************************************************"
    echo " @rxrbln/picorv32 (picosoc directory only to $WORKSPACE/picosoc-ulx3s). Saving log to $THIS_LOG"
    echo "***************************************************************************************************"
    if [ ! -d "$WORKSPACE"/picosoc-ulx3s ]; then
        mkdir -p picosoc-ulx3s
		cd picosoc-ulx3s
		git init
		git remote add rxrbln-picorv32 https://github.com/rxrbln/picorv32.git
		git fetch rxrbln-picorv32
		git checkout  rxrbln-picorv32/master -- picosoc
        cd rxrbln-picorv32
    else
        cd rxrbln-picorv32
		git fetch rxrbln-picorv32
		git checkout  rxrbln-picorv32/master -- picosoc
    fi
fi


sudo apt-get install make        --assume-yes
sudo apt-get install make-guile  --assume-yes
sudo apt-get install libgmp3-dev --assume-yes
sudo apt-get install libmpfr-dev --assume-yes
sudo apt-get install libmpc-dev  --assume-yes

sudo apt-get install autoconf automake autotools-dev curl libmpc-dev \
        libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo \
    gperf libtool patchutils bc zlib1g-dev git libexpat1-dev --assume-yes


if [[ "$1" == *"--picorv32"* ]] || [ "$1" == "" ]; then
    cd "$WORKSPACE"
    THIS_LOG=$LOG_DIRECTORY"/"$THIS_FILE_NAME"_picorv32_"$LOG_SUFFIX".log"

    echo "***************************************************************************************************"
    echo "  picorv32. Saving log to $THIS_LOG"
    echo "***************************************************************************************************"
    if [ ! -d "$WORKSPACE"/picorv32 ]; then
	  git clone --recursive https://github.com/cliffordwolf/picorv32.git 2>&1 | tee -a "$THIS_LOG"
	  cd picorv32
	else
	  cd picorv32
	  git fetch                                                          2>&1 | tee -a "$THIS_LOG"
	  git pull                                                           2>&1 | tee -a "$THIS_LOG"
	fi

	# we are still in ~/workspace/picorv32
	# download tools. We can run this multiple times. the tools won't be blindly re-downloaded
	make download-tools

	# install *all four* riscv flavor toolchains:
	# make -j$(nproc) build-tools

	# or install only riscv32i:
	sudo mkdir -p /opt/riscv32i
	sudo chown $USER /opt/riscv32i
fi

if [[ "$1" == *"--riscv-gnu-toolchain-rv32i"* ]] || [ "$1" == "" ]; then
	cd "$WORKSPACE"
	THIS_LOG=$LOG_DIRECTORY"/"$THIS_FILE_NAME"_riscv-gnu-toolchain-rv32i_"$LOG_SUFFIX".log"


	sudo mkdir -p /opt/riscv32i
	sudo chown $USER /opt/riscv32i


	echo "***************************************************************************************************"
	echo " riscv-gnu-toolchain-rv32i. Saving log to $THIS_LOG"
	echo "***************************************************************************************************"
	if [ ! -d "$WORKSPACE"/riscv-gnu-toolchain-rv32i ]; then
      git clone https://github.com/riscv/riscv-gnu-toolchain riscv-gnu-toolchain-rv32i  2>&1 | tee -a "$THIS_LOG"
      git checkout 411d134
      cd riscv-gnu-toolchain-rv32i

      # if you see fatal: clone of 'git://  ... 
      # users sitting behind a firewall may need these:
      git config --global url.https://github.com/.insteadOf                  git://github.com/
      git config --global url.https://git.qemu.org/git/.insteadOf            git://git.qemu-project.org/
      git config --global url.https://anongit.freedesktop.org/git/.insteadOf git://anongit.freedesktop.org/
      git config --global url.https://github.com/riscv.insteadOf             git://github.com/riscv

      echo "This next step takes a long time. Be patient:"
      git submodule update --init --recursive
    else
	  cd riscv-gnu-toolchain-rv32i
	  git fetch                                                                         2>&1 | tee -a "$THIS_LOG"
	  git pull                                                                          2>&1 | tee -a "$THIS_LOG"
      git submodule update --recursive
      git checkout 411d134
	fi

	# after we have new (or fresh) files, build
    mkdir -p build; 
    cd build
    ../configure --with-arch=rv32i --prefix=/opt/riscv32i
    make -j$(nproc)
fi

# see if it is working:
/opt/riscv32i/bin/riscv32-unknown-elf-gcc --version


# add to path
if [ "$(cat ~/.bashrc | grep  $THIS_RISCV_PATH)" == "" ]; then
  echo PATH=$PATH:$THIS_RISCV_PATH >> ~/.bashrc
  echo "~/.bashrc updated with this line:"
  echo PATH=$PATH:$THIS_RISCV_PATH
else
  echo "Found $THIS_RISCV_PATH in ~/.bashrc - path not changed."
fi

if [ "$(echo $PATH | grep  $THIS_RISCV_PATH)" == "" ]; then
  export PATH=$PATH:$THIS_RISCV_PATH
  echo "Updated current path: $PATH"
else
  echo "Path not updated. PATH=$PATH"
fi



if [[ "$1" == *"--litex"* ]] || [ "$1" == "" ]; then
	cd "$WORKSPACE"
	THIS_LOG=$LOG_DIRECTORY"/"$THIS_FILE_NAME"_litex_"$LOG_SUFFIX".log"

	wget https://raw.githubusercontent.com/enjoy-digital/litex/master/litex_setup.py  2>&1 | tee -a "$THIS_LOG"
	chmod +x litex_setup.py
	sudo ./litex_setup.py install                                                     2>&1 | tee -a "$THIS_LOG"

	cd "$WORKSPACE"
	THIS_LOG=$LOG_DIRECTORY"/"$THIS_FILE_NAME"_linux-on-litex-vexriscv_"$LOG_SUFFIX".log"
	echo "***************************************************************************************************"
	echo " linux-on-litex-vexriscv. Saving log to $THIS_LOG"
	echo "***************************************************************************************************"
	if [ ! -d "$WORKSPACE"/linux-on-litex-vexriscv ]; then
	  git clone --recursive https://github.com/enjoy-digital/linux-on-litex-vexriscv    2>&1 | tee -a "$THIS_LOG"
	  cd linux-on-litex-vexriscv
	else
	  cd linux-on-litex-vexriscv
	  git fetch                                                       2>&1 | tee -a "$THIS_LOG"
	  git pull                                                        2>&1 | tee -a "$THIS_LOG"
	fi

	./make.py --board ULX3S
fi


if [[ "$1" == *"--openocd-esp32"* ]] || [ "$1" == "" ]; then
	cd "$WORKSPACE"
	THIS_LOG=$LOG_DIRECTORY"/"$THIS_FILE_NAME"_openocd-esp32_"$LOG_SUFFIX".log"

	echo "***************************************************************************************************"
	echo " openocd-esp32. Saving log to $THIS_LOG"
	echo "***************************************************************************************************"
	if [ ! -d "$WORKSPACE"/openocd-esp32 ]; then
	  git clone --recursive https://github.com/espressif/openocd-esp32    2>&1 | tee -a "$THIS_LOG"
	  cd openocd-esp32
	else
	  cd openocd-esp32
	  git fetch                                                       2>&1 | tee -a "$THIS_LOG"
	  git pull                                                        2>&1 | tee -a "$THIS_LOG"
	fi
fi


if [[ "$1" == *"--openocd"* ]] || [ "$1" == "" ]; then
    sudo apt install libtool automake pkg-config libusb-1.0-0-dev --assume-yes   2>&1 | tee -a "$THIS_LOG"

	cd "$WORKSPACE"
	THIS_LOG=$LOG_DIRECTORY"/"$THIS_FILE_NAME"_openocd_"$LOG_SUFFIX".log"

	echo "***************************************************************************************************"
	echo " openocd. Saving log to $THIS_LOG"
	echo "***************************************************************************************************"
	if [ ! -d "$WORKSPACE"/openocd ]; then
	  git clone --recursive https://github.com/ntfreak/openocd.git    2>&1 | tee -a "$THIS_LOG"
	  cd openocd
	else
	  cd openocd
	  git fetch                                                       2>&1 | tee -a "$THIS_LOG"
	  git pull                                                        2>&1 | tee -a "$THIS_LOG"
	fi

	./bootstrap
	./configure --enable-ftdi
	make
	sudo make install
fi


sudo apt-get install iverilog


cd ~/workspace
git clone https://gist.github.com/gojimmypi/f96cd86b2b8595b4cf3be4baf493c5a7 ulx3s_fpga_toolchain
cd ulx3s_fpga_toolchain
chmod +x ULX3S_WSL_Toolchain.sh
./ULX3S_WSL_Toolchain.sh


cd $STARTING_PATH

