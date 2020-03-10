# this script is meant to be called at the beginning of other install_[name].sh scripts
export THIS_ULX3S_DEVICE=LFE5U-85F
export THISRISCV=riscv32i
export THIS_RISCV_PATH=/opt/$THISRISCV/bin
export MIN_ULX3S_MEMORY=5040000
export SAVED_CURRENT_PATH=$(pwd)

if [ "$ULX3S_COM" == "" ]; then
  export ULX3S_COM=/dev/ttyS8  # put your device name here
  echo ""
  echo "Warning: setting ULX3S_COM to $ULX3S_COM - consider setting in your .bashrc file."
  echo ""
  read -p "Press enter to continue, or Ctrl-C to abort."
else
  echo "Using ULX3S_COM=$ULX3S_COM"
fi

# active toolchain component developers may wish to set this to something other than the default.
# avaoid spaces in the WORKSPACE path.
if [ "$WORKSPACE" == "" ]; then
  if grep -q Microsoft /proc/version; then
    # Set default WSL location to C:\workspace
    export WORKSPACE=/mnt/c/workspace # put your WSL linux path here. Placed outside of WSL file system for easy refresh
  else
    # Set Ubuntu location to home directory ~/workspace
    export WORKSPACE=~/workspace  # put your pure linux workspace parent directory here.
  fi
fi

# we will keep track of every install with suffixes YYYYMMSS_HHMMSS such as 20200307_105326
export LOG_SUFFIX=$(date +"%Y%m%d_%H%M%S")

# strip any path from $0 to get just the file name of this script, stripping any CR, LF, Tabs
export THIS_FILE_NAME=$(basename $0 .sh | tr --delete '\t\r\n' )

# where the logs will be saved for example ~/workspace/install_logs
export LOG_DIRECTORY="$WORKSPACE/install_logs"

# pretty file names need underscore delimiters in just the right place
if [ "$1" == "" ]; then
  export THIS_PARAM_NAME=""
  THIS_DELIM=""
else
  export THIS_PARAM_NAME=$(basename "$1" .sh | tr --delete '\t\r\n' )
  # echo THIS_PARAM_NAME=$THIS_PARAM_NAME
  THIS_DELIM="_"
fi

# typicaly log file name looks like /mnt/c/workspace/install_logs/install_ujprog_20200307_105326.log
export THIS_LOG=$LOG_DIRECTORY"/"$THIS_FILE_NAME""$THIS_DELIM""$THIS_PARAM_NAME""_""$LOG_SUFFIX".log"

mkdir -p "$WORKSPACE"
mkdir -p "$WORKSPACE/install_logs"

#"***************************************************************************************************"
# check that we are not running as root
#"***************************************************************************************************"
ls /root > /dev/null 2>&1
EXIT_STAT=$?
if [ $EXIT_STAT -ne 0 ];then
  echo "Startup ulx3s toolchain. Security Context:" $(whoami) 2>&1 | tee -a  "$THIS_LOG"
else
  echo "Warning! Do not run as root. Causes undesired install permissions. Enter sudo password as required during setup." 
  read -p "Press enter to continue, or Ctrl-C to abort. (manually push/pull recent file)"
  echo "Startup install with root permissions! (not a good idea) Security Context: $(whoami)" 2>&1 | tee -a  "$THIS_LOG"
fi

cd "$WORKSPACE"
echo ""
echo "Installing to $(pwd)"
