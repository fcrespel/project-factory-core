#!/bin/sh
#
# Log rotation script.
# By Fabien CRESPEL <fabien@crespel.net>
#

LOGROTATE_BIN="/usr/sbin/logrotate"
LOGROTATE_DIR="@{product.app}/system/logrotate"
LOGROTATE_CONF="$LOGROTATE_DIR/logrotate.conf"

chown -R root "$LOGROTATE_DIR"
$LOGROTATE_BIN "$LOGROTATE_CONF"
