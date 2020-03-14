#!/bin/bash
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

CheckForError $1 $2 $3 $4 $5
