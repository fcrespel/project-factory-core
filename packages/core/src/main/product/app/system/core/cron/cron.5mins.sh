#!/bin/bash
#
# Cron 'every five minutes' exec script.
# By Fabien CRESPEL <fabien@crespel.net>
#

. "@{product.bin}/functions.sh"
CRON_DIR="@{product.bin}/cron.5mins"

run_cron_scripts "$CRON_DIR"
