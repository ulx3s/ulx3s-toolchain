#!/bin/bash
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
	GIT_THIS_BRANCH=$(git rev-parse --abbrev-ref HEAD)
	cd $GIT_FULL_PATH

	echo "Checking $GIT_FULL_PATH/$GIT_FILE_NAME on branch origin/$GIT_THIS_BRANCH"

	# compares occur to local files only, so quietly fetch
	git fetch > /dev/null

	# we first need to get the latest commit hash (non-blank if remote is newer)
	COMMIT_HASH=$(git show --format=%H --no-patch --no-abbrev-commit HEAD..origin/$GIT_THIS_BRANCH)

	# view the file in the commit hash found and pipe to `git hash-object` to compute hash
	GIT_HASH=$(git show $COMMIT_HASH:$1 | git hash-object --stdin )

	# simple `git hash-object` to compute hash of the local file
	THIS_HASH=$(git hash-object $1)

	# some visual entertainment
	echo "Remote URL  = $(git config --get remote.origin.url)"
	echo "COMMIT_HASH = $COMMIT_HASH"
	echo "GIT_HASH    = $GIT_HASH"
	echo "THIS_HASH   = $THIS_HASH"

	if [ "$THIS_HASH" == "$GIT_HASH" ]; then
		echo "Confirmed $1 is the most recent version found in GitHub."
	else 
		echo "Warning! This version of $1 does not match the most recent version in GitHub!"
		git status | tr -s ' ' | grep "modified: $1"
		# read -p "Press enter to continue, or Ctrl-C to abort. (manually push/pull recent file)"
	fi
	cd $SAVED_CURRENT_PATH
}
CheckForGitFileChange $1
