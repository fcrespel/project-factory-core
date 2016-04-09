#!/bin/bash
#
# Disable service script.
# By Fabien CRESPEL <fabien@crespel.net>
#

# Shared routines
SCRIPT_DIR=`dirname "$0"`
. "$SCRIPT_DIR/../loadenv.sh"

# Script variables
INIT_DIR="$PRODUCT_BIN/init.d"
SERVICE_NAME="${1%.sh}"
SERVICE_FILE="$INIT_DIR/$SERVICE_NAME.sh"

# Check user
if [ "$(whoami)" != "root" ]; then
	echo "You must be root to run this command"
	exit 1
fi

# Check arguments
if [ -z "$SERVICE_NAME" ]; then
	echo "Usage: $0 <service name>"
	echo "Available services: "
	find "$INIT_DIR" -name '*.sh' -printf '%f\n' | sort | while read SERVICE; do
		echo "  ${SERVICE%.sh}"
	done
	exit 1
elif [ ! -e "$SERVICE_FILE" ]; then
	echo "Service $SERVICE_NAME does not exist."
	exit 2
fi

# Disable service
disableservice $PRODUCT_ID-$SERVICE_NAME
