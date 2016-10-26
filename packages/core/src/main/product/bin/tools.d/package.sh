#!/bin/bash
#
# Package management script.
# By Fabien CRESPEL <fabien@crespel.net>
#

# Shared routines
SCRIPT_DIR=`dirname "$0"`
. "$SCRIPT_DIR/../loadenv.sh"

# Script variables
ACTION="$1"
PACKAGE_TYPE="$2"
PACKAGE_NAME="$3"
PACKAGE="${PACKAGE_PREFIX}-${PACKAGE_TYPE}-${PACKAGE_NAME}"

# Check arguments
if [ -z "$ACTION" ]; then
	echo "Usage: $0 list [system|admin|service]"
	echo "       $0 <install|update|remove> <system|admin|service> <package name>"
	exit 1
fi

# Perform action
case "$ACTION" in
	"list")
		listpackages "$PACKAGE_PREFIX-$PACKAGE_TYPE"
		;;
	"install"|"update"|"remove")
		if [ -z "$PACKAGE_TYPE" ]; then
			echo "Missing package type argument"
			exit 2
		elif [ -z "$PACKAGE_NAME" ]; then
			echo "Missing package name argument"
			exit 3
		else
			${ACTION}package "$PACKAGE"
		fi
		;;
	*)
		echo "Unknown action '$ACTION'"
		;;
esac
