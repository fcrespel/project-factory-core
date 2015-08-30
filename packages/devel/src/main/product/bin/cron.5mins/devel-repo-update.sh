#!/bin/sh
#
# Local development repository update script.
# By Fabien CRESPEL <fabien@crespel.net>
#

REPO_DIR="@{product.data}/system/maven/repository"
LOG_FILE="@{package.log}/repo_update.log"
DATE=`date --rfc-3339=seconds`

echo "[$DATE]" >> "$LOG_FILE"

# Update local Yum repository
if which createrepo > /dev/null 2>&1; then
	createrepo --update "$REPO_DIR" >> "$LOG_FILE"
fi

# Update local Debian repository
if which dpkg-scanpackages > /dev/null 2>&1; then
	( cd "$REPO_DIR" && dpkg-scanpackages . 2>> "$LOG_FILE" | gzip -9c > "$REPO_DIR/Packages.gz" )
fi

echo >> "$LOG_FILE"
