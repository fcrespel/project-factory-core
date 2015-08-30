#!/bin/bash
#
# Backup exec script.
# By Fabien CRESPEL <fabien@crespel.net>
#

BACKUP_DIR="@{product.bin}/backup.d"
LOG_FILE="@{package.log}/backup.log"

# Print header
echo "===============================================================================" >> "$LOG_FILE"
echo "[$(date --rfc-3339=seconds)] BACKUP STARTING" >> "$LOG_FILE"
echo "===============================================================================" >> "$LOG_FILE"

# Execute all backup scripts in order
FAILURE=0
for BACKUP_SCRIPT in `find "$BACKUP_DIR" -mindepth 1 -name '*.sh' | sort`; do
	if [ -z "$BACKUP_SCRIPT" ]; then
		continue;
	fi
	echo >> "$LOG_FILE"
	echo "-------------------------------------------------------------------------------" >> "$LOG_FILE"
	echo "[$(date --rfc-3339=seconds)] Executing: $BACKUP_SCRIPT" >> "$LOG_FILE"
	echo "-------------------------------------------------------------------------------" >> "$LOG_FILE"
	echo >> "$LOG_FILE"
	chmod +x "$BACKUP_SCRIPT"
	if "$BACKUP_SCRIPT" >> "$LOG_FILE" 2>&1; then
		echo "$BACKUP_SCRIPT completed successfully" >> "$LOG_FILE"
	else
		EXITCODE=$?
		FAILURE=1
		echo >> "$LOG_FILE"
		echo "ERROR: $BACKUP_SCRIPT failed with exit code: $EXITCODE" >> "$LOG_FILE"
		echo "ERROR: $BACKUP_SCRIPT failed with exit code: $EXITCODE"
		echo >> "$LOG_FILE"
	fi
done

# Print final status
echo >> "$LOG_FILE"
echo "===============================================================================" >> "$LOG_FILE"
if [ $FAILURE -eq 0 ]; then
	echo "[$(date --rfc-3339=seconds)] BACKUP COMPLETED SUCCESSFULLY" >> "$LOG_FILE"
else
	echo "[$(date --rfc-3339=seconds)] BACKUP COMPLETED WITH ERRORS" >> "$LOG_FILE"
	echo
	echo "BACKUP COMPLETED WITH ERRORS - SEE LOG FILE: $LOG_FILE"
	echo
fi
echo "===============================================================================" >> "$LOG_FILE"
echo >> "$LOG_FILE"

exit $FAILURE
