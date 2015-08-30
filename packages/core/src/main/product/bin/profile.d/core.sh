#!/bin/sh
#
# Core profile configuration.
# By Fabien CRESPEL <fabien@crespel.net>
#

umask 022

TOOLS_DIR="@{product.bin}/tools.d"
if [ -e "$TOOLS_DIR" ]; then
    export PATH="$TOOLS_DIR:$PATH"
fi
