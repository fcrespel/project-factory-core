#!/bin/bash
#
# Set configuration script.
# By Fabien CRESPEL <fabien@crespel.net>
#

# Shared routines
SCRIPT_DIR=`dirname "$0"`
. "$SCRIPT_DIR/../loadenv.sh"

# Script variables
CONFIG_KEY="$1"
CONFIG_VALUE="$2"

# Check arguments
if [ -z "$CONFIG_KEY" ]; then
	echo "Usage: $0 <key> [value]"
	exit 1
fi

# Set variable
storevar "$CONFIG_KEY" "$CONFIG_VALUE"
