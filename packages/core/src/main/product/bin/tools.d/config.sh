#!/bin/bash
#
# Configuration management script.
# By Fabien CRESPEL <fabien@crespel.net>
#

# Shared routines
SCRIPT_DIR=`dirname "$0"`
. "$SCRIPT_DIR/../loadenv.sh"

# Script variables
ACTION="$1"
CONFIG_KEY="$2"
CONFIG_VALUE="$3"

# Check arguments
if [ -z "$ACTION" ]; then
	echo "Usage: $0 list"
	echo "       $0 get <key>"
	echo "       $0 <set|add|remove> <key> <value>"
	exit 1
fi

# Perform action
case "$ACTION" in
	"list")
		listvars
		;;
	"get")
		echo "${!CONFIG_KEY}"
		;;
	"set")
		storevar "$CONFIG_KEY" "$CONFIG_VALUE"
		;;
	"add")
		addvar "$CONFIG_KEY" "$CONFIG_VALUE"
		;;
	"remove")
		removevar "$CONFIG_KEY" "$CONFIG_VALUE"
		;;
	*)
		echo "Unknown action '$ACTION'"
		;;
esac
