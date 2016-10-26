#!/bin/bash
#
# Service management script.
# By Fabien CRESPEL <fabien@crespel.net>
#

# Shared routines
SCRIPT_DIR=`dirname "$0"`
. "$SCRIPT_DIR/../loadenv.sh"

# Script variables
INIT_DIR="$PRODUCT_BIN/init.d"
ACTION="$1"
SERVICE_NAME="${2%.sh}"
SERVICE_FILE="$INIT_DIR/$SERVICE_NAME.sh"

# Check user
if [ "$(whoami)" != "root" ]; then
	echo "You must be root to run this command"
	exit 1
fi

# Check arguments
if [ -z "$ACTION" -o -z "$SERVICE_NAME" ]; then
	echo "Usage: $0 <enable|start|status|reload|stop|disable> <service name>"
	echo "Available services: "
	find "$INIT_DIR" -name '*.sh' -printf '%f\n' | sort | while read SERVICE; do
		echo "  ${SERVICE%.sh}"
	done
	exit 1
elif [ ! -e "$SERVICE_FILE" ]; then
	echo "Service $SERVICE_NAME does not exist."
	exit 2
fi

# Perform action
case "$ACTION" in
	"enable")
		enableservice "$PRODUCT_ID-$SERVICE_NAME" force
		;;
	"start")
		startservice "$PRODUCT_ID-$SERVICE_NAME"
		;;
	"status")
		statusservice "$PRODUCT_ID-$SERVICE_NAME"
		;;
	"reload")
		reloadservice "$PRODUCT_ID-$SERVICE_NAME"
		;;
	"stop")
		stopservice "$PRODUCT_ID-$SERVICE_NAME"
		;;
	"disable")
		disableservice "$PRODUCT_ID-$SERVICE_NAME" force
		;;
	*)
		echo "Unknown action '$ACTION'"
		;;
esac
