#!/bin/bash
#
# Cron hourly exec script.
# By Fabien CRESPEL <fabien@crespel.net>
#

. "@{product.bin}/functions.sh"
CRON_DIR="@{product.bin}/cron.hourly"

run_cron_scripts "$CRON_DIR"
