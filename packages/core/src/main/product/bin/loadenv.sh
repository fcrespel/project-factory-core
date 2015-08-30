#!/bin/bash
#
# Project Factory - Core Environment Loader
# By Fabien CRESPEL <fabien@crespel.net>
#

# Core data directory
CORE_DATA_DIR="@{product.data}/system/core"

# Include shared functions
for FILE in @{product.bin}/functions*.sh; do
	. $FILE
done

# Load configuration file
if [ -f "$CORE_DATA_DIR/config.sh" ]; then
	. "$CORE_DATA_DIR/config.sh"
fi

# Load passwords file and ensure its permissions are reasonable
if [ -f "$CORE_DATA_DIR/passwd.sh" ]; then
	chmod 550 "$CORE_DATA_DIR/passwd.sh"
	. "$CORE_DATA_DIR/passwd.sh"
fi

# Configure proxy
if [ -n "$PROXY_HOST" -a -n "$PROXY_PORT" ] && [ "$PROXY_PORT" -gt 0 ]; then
	export HTTP_PROXY="http://$PROXY_HOST:$PROXY_PORT"
	export http_proxy="http://$PROXY_HOST:$PROXY_PORT"
	export HTTPS_PROXY="http://$PROXY_HOST:$PROXY_PORT"
	export https_proxy="http://$PROXY_HOST:$PROXY_PORT"
	export FTP_PROXY="http://$PROXY_HOST:$PROXY_PORT"
	export ftp_proxy="http://$PROXY_HOST:$PROXY_PORT"
	export NO_PROXY="$PRODUCT_DOMAIN"
	export no_proxy="$PRODUCT_DOMAIN"
fi
