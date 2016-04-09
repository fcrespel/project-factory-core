#!/bin/bash
#
# Administration script.
# By Fabien CRESPEL <fabien@crespel.net>
#

# Shared routines
SCRIPT_DIR="@{product.bin}"
. "$SCRIPT_DIR/loadenv.sh"

# Script variables
TOOLS_DIR="$SCRIPT_DIR/tools.d"
COMMAND_NAME="${1%.sh}"
COMMAND_FILE="$TOOLS_DIR/$COMMAND_NAME.sh"

# Check argument
if [ -z "$COMMAND_NAME" -o "$COMMAND_NAME" = "help" -o "$COMMAND_NAME" = "?" ]; then
	echo "Usage: $0 <command name> [command options ...]"
	echo "Available commands: "
	find "$TOOLS_DIR" -name '*.sh' -printf '%f\n' | sort | while read COMMAND; do
		echo "  ${COMMAND%.sh}"
	done
	exit 1
elif [ ! -e "$COMMAND_FILE" ]; then
	echo "Command $COMMAND_NAME does not exist."
	exit 2
fi

# Execute command
shift
[ -x "$COMMAND_FILE" ] || chmod +x "$COMMAND_FILE"
"$COMMAND_FILE" "$@"
