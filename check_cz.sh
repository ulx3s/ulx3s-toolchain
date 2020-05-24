#!/bin/bash
#"***************************************************************************************************"
#  check to see if we can reach https://repo.or.cz/jimtcl.git/ (used by OpenOCD; some firewalls may block this)
#
#  prompt install early on, rather than pausing for error hours later.
#"***************************************************************************************************"

THIS_CZ=$(curl --silent https://repo.or.cz/jimtcl.git/ | grep -m 1 .)
if [ "$?" != "0" ] || [ "$THIS_CZ" == "" ] ; then
  echo ""
  echo "Warning! Unable to reach https://repo.or.cz (needed for OpenOCD)"
  echo ""
  echo "Check your firewall or network connection."
  echo ""
  read -p "Press enter to continue and skip using repo.or.cz, or Ctrl-C to abort."
  echo ""
  echo "Continuing install WITHOUT OpenOCD fetch!"
  echo ""
  export THIS_SKIP_CZ=true
else
  echo "Confirmed https://repo.or.cz/jimtcl.git/"
fi