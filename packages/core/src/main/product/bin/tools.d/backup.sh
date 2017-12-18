#!/bin/bash
#
# Backup script.
# By Fabien CRESPEL <fabien@crespel.net>
#

# Shared routines
SCRIPT_DIR=`dirname "$0"`
. "$SCRIPT_DIR/../loadenv.sh"

# Script variables
BACKUP_DIR="$PRODUCT_BIN/backup.d"
SERVICE_NAME="${1%.sh}"
BACKUP_SCRIPT="$BACKUP_DIR/backup-$SERVICE_NAME.sh"

# Check user
if [ "$(whoami)" != "root" ]; then
	echo "You must be root to run this command"
	exit 1
fi

# Check arguments
if [ -z "$SERVICE_NAME" ]; then
	echo "Usage: $0 <service name> [arguments ...]"
	echo "Available services: "
	find "$BACKUP_DIR" -name 'backup-*.sh' -printf '%f\n' | sort | while read SERVICE; do
		SERVICE="${SERVICE#backup-}"
		echo "  ${SERVICE%.sh}"
	done
	exit 1
elif [ ! -e "$BACKUP_SCRIPT" ]; then
	echo "Service $SERVICE_NAME does not exist or does not support backup."
	exit 2
fi

# Execute backup
echo "Executing $BACKUP_SCRIPT ..."
chmod +x "$BACKUP_SCRIPT"
if "$BACKUP_SCRIPT" "${@:2}"; then
	echo "$BACKUP_SCRIPT completed successfully"
else
	RET=$?
	echo "ERROR: $BACKUP_SCRIPT failed with exit code: $RET"
	exit $RET
fi
