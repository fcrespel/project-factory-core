#!/bin/bash
#
# Get configuration script.
# By Fabien CRESPEL <fabien@crespel.net>
#

# Shared routines
SCRIPT_DIR=`dirname "$0"`
. "$SCRIPT_DIR/../loadenv.sh"

# Script variables
CONFIG_KEY="$1"

# Check arguments
if [ -z "$CONFIG_KEY" ]; then
	echo "Usage: $0 <key>"
	exit 1
fi

# Get variable
echo "${!CONFIG_KEY}"
