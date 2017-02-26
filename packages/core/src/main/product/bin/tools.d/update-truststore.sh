#!/bin/bash
#
# Java trust store update script.
# By Fabien CRESPEL <fabien@crespel.net>
#

# Shared routines
SCRIPT_DIR=`dirname "$0"`
. "$SCRIPT_DIR/../loadenv.sh"

# Script variables
TRUSTSTORE="$1"
TRUSTSTORE_IMPORT="$2"

# Check arguments
if [ -z "$TRUSTSTORE" ]; then
	echo "Usage: $0 <truststore.jks | all> [import.jks]"
	exit 1
fi

# Perform action
if [ "$TRUSTSTORE" = "all" ]; then
	# Update all trust stores
	find "$PRODUCT_APP" -name "trust.jks" | while read TRUSTSTORE; do
		if create_truststore "$TRUSTSTORE" "" "" "$TRUSTSTORE_IMPORT"; then
			echo "Trust store '$TRUSTSTORE' successfully updated"
		else
			echo "Failed to update '$TRUSTSTORE'"
			exit 2
		fi
	done
else
	# Update specific trust store
	if [ -e "$TRUSTSTORE" ]; then
		if create_truststore "$TRUSTSTORE" "" "" "$TRUSTSTORE_IMPORT"; then
			echo "Trust store '$TRUSTSTORE' successfully updated"
		else
			echo "Failed to update '$TRUSTSTORE'"
			exit 2
		fi
	else
		echo "ERROR: trust store '$TRUSTSTORE' does not exist"
		exit 1
	fi
fi
