#!/bin/bash
#"***************************************************************************************************"
#  common initialization
#"***************************************************************************************************"

# select master or some GitHub hash version, and whether or not to force a clean
THIS_CHECKOUT=master
THIS_CLEAN=true

# perform some version control checks on this file
./gitcheck.sh $0

# initialize some environment variables and perform some sanity checks
. ./init.sh

# we don't want tee to capture exit codes
set -o pipefail

#"***************************************************************************************************"
# fetch @DoctorWkt FPGA ULX3S-Blinky into workspace
#"***************************************************************************************************"

echo "***************************************************************************************************"
echo "@DoctorWkt ULX3S-Blinky. Saving log to $THIS_LOG"
echo "***************************************************************************************************"

# Call the common github checkout:

pushd .
cd "$WORKSPACE"

$SAVED_CURRENT_PATH/fetch_github.sh https://github.com/DoctorWkt/ULX3S-Blinky ULX3S-Blinky $THIS_CHECKOUT  2>&1 | tee -a "$THIS_LOG"
$SAVED_CURRENT_PATH/check_for_error.sh                                                                       $?          "$THIS_LOG"

cd "$WORKSPACE"/ULX3S-Blinky

# make  # --> will produce errors
        # verilator -O3 -MMD --trace -Wall -cc blinky.v
        # %Error: blinky.v:5:10: Duplicate declaration of signal: 'i_clk'
        #                     : ... note: ANSI ports must have type declared with the I/O (IEEE 1800-2017 23.2.2.2)
        #     5 |     wire i_clk;
        #     |          ^~~~~
        #         blinky.v:3:21: ... Location of original declaration
        #     3 | module blinky(input i_clk, input [6:0] btn, output [7:0] o_led);
        #     |                     ^~~~~
        # %Error: blinky.v:6:16: Duplicate declaration of signal: 'btn'
        #     6 |     wire [6:0] btn;
        #     |                ^~~
        #         blinky.v:3:40: ... Location of original declaration
        #     3 | module blinky(input i_clk, input [6:0] btn, output [7:0] o_led);
        #     |                                        ^~~
        # %Error: blinky.v:7:16: Duplicate declaration of signal: 'o_led'
        #     7 |     wire [7:0] o_led;
        #     |                ^~~~~
        #         blinky.v:3:58: ... Location of original declaration
        #     3 | module blinky(input i_clk, input [6:0] btn, output [7:0] o_led);
        #     |                                                          ^~~~~
        # %Error: Exiting due to 3 error(s)

popd
echo "Completed $0 "                                                  | tee -a "$THIS_LOG"
echo "----------------------------------"
