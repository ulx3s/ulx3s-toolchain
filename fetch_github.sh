#!/bin/bash
#"***************************************************************************************************"
#  fetch_github.sh URL directoryName [hash]
#"***************************************************************************************************"
# when we get here, we are typically already in $WORKSPACE, ready to clone to a new directory
#
# perform some version control checks on this file
# $SAVED_CURRENT_PATH/gitcheck.sh $0
#
# we don't want tee to capture exit codes
set -o pipefail

# ensure we alwaye start from the $WORKSPACE directory
cd "$WORKSPACE"

echo ""
echo "fetch_github.sh working directory: $(pwd) with parameters:"
echo ""

THIS_REPO_URL=$1
THIS_DIR=$2
THIS_CHECKOUT=$3
THIS_ERROR=0

echo "THIS_REPO_URL = $THIS_REPO_URL"
echo "THIS_DIR      = $THIS_DIR"
echo "THIS_CHECKOUT = $THIS_CHECKOUT"
echo ""

if [ "$THIS_DIR" != "" ]; then

    if [ ! -d "$WORKSPACE"/$THIS_DIR ]; then
      echo ""
      echo "git clone $THIS_REPO_URL $THIS_DIR"
      git clone --recursive $THIS_REPO_URL $THIS_DIR
      if [ "$?" != "0" ]; then
        echo ""
        echo "Error encountered during: git clone --recursive $THIS_REPO_URL $THIS_DIR"
        exit 1
      fi
  
      cd $THIS_DIR
    else
      cd $THIS_DIR
      git remote show origin
      THIS_UPSTREAM=$(git remote show origin | grep Fetch)
      echo ""
      echo "git fetch; # using upstream: $THIS_UPSTREAM"
      git fetch
      if [ "$?" != "0" ]; then
        echo ""
        echo "Error encountered during: git fetch; # $THIS_UPSTREAM"
        exit 1
      fi

      echo ""
      echo "git submodule update; # $THIS_UPSTREAM"
      git submodule update
      if [ "$?" != "0" ]; then
        echo ""
        echo "Error encountered during: git submodule update; # $THIS_UPSTREAM"
        exit 1
      fi

      # before pulling in changes, check out master to ensure we are not detached
      echo ""
      echo "git checkout master; # $THIS_UPSTREAM"
      git checkout master
      if [ "$?" != "0" ]; then
        echo ""
        echo "Error encountered during: git checkout master; # $THIS_UPSTREAM"
        echo ""
        echo "Consider: git checkout .   # warning! abandon all changes and check everything out"
        exit 1
      fi

      echo ""
      echo "git pull; # $THIS_UPSTREAM"
      echo ""
      git pull
      if [ "$?" != "0" ]; then
        echo ""
        echo "Error encountered during: git pull; # $THIS_UPSTREAM"
        echo ""
        echo "Consider: git clean -df    # warning! recursive, forced removal of untracked directories in addition to untracked files"
        echo "  and   : git checkout .   # warning! abandon all changes and check everything out"
        echo ""
        exit 1
      fi

      echo ""
      echo "My checkout = $THIS_CHECKOUT; upstream = $THIS_UPSTREAM"
      if [ "$THIS_CHECKOUT" != "" ] && [ "$THIS_CHECKOUT" != "master" ]; then
        echo ""
        echo "git checkout $THIS_CHECKOUT; # $THIS_REPO_URL"
        git checkout $THIS_CHECKOUT
        if [ "$?" != "0" ]; then
          echo ""
          echo "Error encountered during: git checkout $THIS_CHECKOUT; # $THIS_REPO_URL"
          exit 1
        fi
      fi

    fi
else
    echo ""
    echo "ERROR: Missing parameters for fetch_github.sh"
    echo ""
    echo "fetch_github.sh URL directoryName [hash]"
    exit 1
fi

echo "git log: $(git log --pretty=format:'%h' -n 1)"
echo ""
