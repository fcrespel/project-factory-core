#!/bin/bash
#
# Restore script.
# By Fabien CRESPEL <fabien@crespel.net>
#

# Shared routines
SCRIPT_DIR=`dirname "$0"`
. "$SCRIPT_DIR/../loadenv.sh"

# Script variables
BACKUP_DIR="$PRODUCT_BIN/backup.d"
SERVICE_NAME="${1%.sh}"
RESTORE_SCRIPT="$BACKUP_DIR/restore-$SERVICE_NAME.sh"

# Check user
if [ "$(whoami)" != "root" ]; then
	echo "You must be root to run this command"
	exit 1
fi

# Check arguments
if [ -z "$SERVICE_NAME" ]; then
	echo "Usage: $0 <service name> [arguments ...]"
	echo "Available services: "
	find "$BACKUP_DIR" -name 'restore-*.sh' -printf '%f\n' | sort | while read SERVICE; do
		SERVICE="${SERVICE#restore-}"
		echo "  ${SERVICE%.sh}"
	done
	exit 1
elif [ ! -e "$RESTORE_SCRIPT" ]; then
	echo "Service $SERVICE_NAME does not exist or does not support restore."
	exit 2
fi

# Execute restore
echo "Executing $RESTORE_SCRIPT ..."
chmod +x "$RESTORE_SCRIPT"
if "$RESTORE_SCRIPT" "${@:2}"; then
	echo "$RESTORE_SCRIPT completed successfully"
else
	RET=$?
	echo "ERROR: $RESTORE_SCRIPT failed with exit code: $RET"
	exit $RET
fi
