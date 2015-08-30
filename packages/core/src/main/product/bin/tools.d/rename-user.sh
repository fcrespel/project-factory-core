#!/bin/bash
#
# Cross-service user renaming script.
# By Fabien CRESPEL <fabien@crespel.net>
#

# Shared routines
SCRIPT_DIR=`dirname "$0"`
. "$SCRIPT_DIR/../loadenv.sh"

# Script variables
RENAME_FROM="$1"
RENAME_TO="$2"

# Check arguments
if [ -z "$RENAME_FROM" -o -z "$RENAME_TO" ]; then
	echo "Usage: $0 <source username> <target username>"
	exit 1
fi

# Print header
printinfo "Renaming $RENAME_FROM to $RENAME_TO ..."

# Execute all rename scripts in order
find "$SCRIPT_DIR" -maxdepth 1 -name 'rename-user-*.sh' | sort | while read RENAME_SCRIPT; do
	echo
	echo "Executing: $RENAME_SCRIPT"
	[ -x "$RENAME_SCRIPT" ] || chmod +x "$RENAME_SCRIPT"
	"$RENAME_SCRIPT" "$RENAME_FROM" "$RENAME_TO"
	EXITCODE=$?
	if [ $EXITCODE -ne 0 ]; then
		echo
		printerror "ERROR: last script failed with exit code: $EXITCODE"
		printerror "Renaming aborted."
		exit 1
	fi
done
