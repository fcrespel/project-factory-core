#!/bin/bash
#
# Mass processing script.
# By Fabien CRESPEL <fabien@crespel.net>
#

# Shared routines
SCRIPT_DIR=`dirname "$0"`
. "$SCRIPT_DIR/../loadenv.sh"

# Script variables
SCRIPT_FILE="$1"
ARGS_FILE="$2"
ESCAPE="\\"
QUOTE='"'
SEPARATOR="==============================================================================="

# Check arguments
if [ -z "$SCRIPT_FILE" -o -z "$ARGS_FILE" ]; then
	echo "Usage: $0 <script file> <args file>"
	exit 1
fi
if [ ! -e "$SCRIPT_FILE" ]; then
	echo "Script file '$SCRIPT_FILE' does not exist"
	exit 1
fi
if [ ! -e "$ARGS_FILE" ]; then
	echo "Arguments file '$ARGS_FILE' does not exist"
	exit 1
fi

# Header
printinfo $SEPARATOR
printinfo "Mass processing - Script: $SCRIPT_FILE - File: $ARGS_FILE"
printinfo $SEPARATOR
echo

# Read each arguments line and call the script with it
cat "$ARGS_FILE" | sed -r "s#^${QUOTE}|${QUOTE}\$##g" | awk -v FS="${QUOTE}?[,; \t]+${QUOTE}?" -v OFS="${QUOTE} ${QUOTE}" -v QUOTE="${QUOTE}" -v ESCAPE="${ESCAPE}" \
	'{ $1=$1; for (i=1; i<=NF; i++) gsub(QUOTE, ESCAPE ESCAPE QUOTE, $i); print QUOTE $0 QUOTE }' | while read ARGS; do
	echo
	printinfo $SEPARATOR
	printinfo "Executing: $SCRIPT_FILE $ARGS"
	printinfo $SEPARATOR
	echo
	eval "$SCRIPT_FILE" $ARGS
	EXITCODE=$?
	if [ $EXITCODE -ne 0 ]; then
		echo
		printerror $SEPARATOR
		printerror "ERROR: last script failed with exit code: $EXITCODE"
		printerror $SEPARATOR
		echo
		printerror "Mass processing aborted."
		exit 1
	else
		echo
		printsuccess "Script terminated successfully."
	fi
done

# Footer
echo
printinfo $SEPARATOR
printinfo "Mass processing finished"
printinfo $SEPARATOR

exit 0
