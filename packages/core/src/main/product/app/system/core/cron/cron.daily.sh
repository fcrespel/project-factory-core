#!/bin/bash
#
# Cron daily exec script.
# By Fabien CRESPEL <fabien@crespel.net>
#

. "@{product.bin}/functions.sh"
CRON_DIR="@{product.bin}/cron.daily"

run_cron_scripts "$CRON_DIR"
