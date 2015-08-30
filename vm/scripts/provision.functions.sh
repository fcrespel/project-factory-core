#!/bin/sh
#
# Project Factory VM Provisioning Functions
# By Fabien CRESPEL <fabien@crespel.net>
#

# Install packages if they are not already available
function installpackages
{
	local PACKAGES="$1"
	local PACKAGES_TOINSTALL=""
	for PACKAGE in $PACKAGES; do
		if rpm -q "$PACKAGE" 2>&1 > /dev/null; then
			echo -n "> Already installed: "
			rpm -q "$PACKAGE"
		else
			PACKAGES_TOINSTALL="$PACKAGES_TOINSTALL $PACKAGE"
		fi
	done
	if [ -z "$PACKAGES_TOINSTALL" ]; then
		echo "> Nothing to install."
	else
		echo "> Installing: $PACKAGES_TOINSTALL"
		echo
		if ! yum -y -e 0 install $PACKAGES_TOINSTALL; then
			return 1
		fi
	fi
	return 0
}

# Interpolate all %{PLACEHOLDERS} in a file with the corresponding $VARIABLE
function interpolatetemplate
{
	local TEMPLATE_FILE="$1"
	local VARS=`grep -o -E '%\{[A-Z1-9_]+\}' "$TEMPLATE_FILE" | sort | uniq | sed 's#[%{}]##g'`
	local CMD="cat \"$TEMPLATE_FILE\""
	if [ ! -z "$VARS" ]; then
		for VAR in $VARS; do
			CMD="$CMD | sed \"s#%{$VAR}#\$$VAR#g\""
		done
	fi
	eval $CMD
}

# Install an overlay over an application's files, interpolating .template files as needed
function installoverlay
{
	local OVERLAY_DIR="$1"
	local TARGET_DIR="$2"
	local TMP_DIR=`mktemp -d`
	if [ ! -e "$TMP_DIR" ]; then
		printerror "ERROR: failed to create temporary directory to interpolate overlay"
		return 1
	fi
	
	# Copy the overlay to a temporary directory, excluding .svn dirs
	rsync -rltDE --exclude='.svn' "$OVERLAY_DIR/" "$TMP_DIR"
	
	# Interpolate all .template files
	find "$TMP_DIR" -type f -name '*.template' | while read TEMPLATE_FILE; do
		INTERPOLATED_FILE="${TEMPLATE_FILE%.template}"
		interpolatetemplate "$TEMPLATE_FILE" > "$INTERPOLATED_FILE"
	done
	
	# Make all .sh scripts executable
	find "$TMP_DIR" -type f -name '*.sh' -exec chmod +x '{}' \;
	
	# Copy interpolated overlay to target dir, excluding .template file
	rsync -rltcDE --exclude='*.template' "$TMP_DIR/" "$TARGET_DIR"
	
	# Delete temporary directory
	rm -Rf "$TMP_DIR"
}
