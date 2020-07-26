#!/bin/bash
#"***************************************************************************************************"
#  check to see if we can reach https://repo.or.cz/jimtcl.git/ (used by OpenOCD; some firewalls may block this)
#
#  prompt install early on, rather than pausing for error hours later.
#"***************************************************************************************************"
echo "Checking for wget install..."
sudo apt-get install wget --assume-yes

THIS_CZ=$(wget --no-hsts --quiet --output-document=- https://repo.or.cz/jimtcl.git/ |  grep -m 1 .)
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
  exit 1
else
  echo "Confirmed https://repo.or.cz/jimtcl.git/"
  exit 0
fi
