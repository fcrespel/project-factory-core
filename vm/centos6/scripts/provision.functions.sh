#!/bin/sh
#
# Project Factory VM Provisioning Functions
# By Fabien CRESPEL <fabien@crespel.net>
#

# Install packages if they are not already available
function installpackages
{
	local PACKAGES="$*"
	local PACKAGES_TOINSTALL=""
	for PACKAGE in $PACKAGES; do
		PACKAGE_BASENAME=`basename "$PACKAGE"`
		PACKAGE_BASENAME="${PACKAGE_BASENAME%.rpm}"
		PACKAGE_BASENAME="${PACKAGE_BASENAME%.deb}"
		if which rpm > /dev/null 2>&1; then
			if rpm -q "$PACKAGE_BASENAME" 2>&1 > /dev/null; then
				echo "> Already installed:" `rpm -q "$PACKAGE_BASENAME"`
			else
				PACKAGES_TOINSTALL="$PACKAGES_TOINSTALL $PACKAGE"
			fi
		elif which dpkg-query > /dev/null 2>&1; then
			if dpkg-query -s "$PACKAGE_BASENAME" 2>&1 > /dev/null; then
				echo "> Already installed:" `dpkg-query -W "$PACKAGE_BASENAME"`
			else
				PACKAGES_TOINSTALL="$PACKAGES_TOINSTALL $PACKAGE"
			fi
		else
			echo "ERROR: failed to detect package manager"
			return 1
		fi
	done
	if [ -z "$PACKAGES_TOINSTALL" ]; then
		echo "> Nothing to install."
	else
		echo "> Installing: $PACKAGES_TOINSTALL"
		echo
		if which yum > /dev/null 2>&1; then
			if ! yum -y -e 0 install $PACKAGES_TOINSTALL; then
				return 1
			fi
		elif which zypper > /dev/null 2>&1; then
			if ! zypper -n install -l $PACKAGES_TOINSTALL; then
				return 1
			fi
		elif which apt-get > /dev/null 2>&1; then
			if ! apt-get -y install $PACKAGES_TOINSTALL; then
				return 1
			fi
		else
			echo "ERROR: failed to detect package manager"
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
	rsync -a --exclude='.svn' "$OVERLAY_DIR/" "$TMP_DIR"
	
	# Interpolate all .template files
	find "$TMP_DIR" -type f -name '*.template' | while read TEMPLATE_FILE; do
		INTERPOLATED_FILE="${TEMPLATE_FILE%.template}"
		interpolatetemplate "$TEMPLATE_FILE" > "$INTERPOLATED_FILE"
	done
	
	# Make all .sh scripts and .so shared libs executable
	find "$TMP_DIR" -type f -name '*.sh' -exec chmod +x '{}' \;
	find "$TMP_DIR" -type f -name '*.so' -exec chmod +x '{}' \;
	find "$TMP_DIR" -type f -name '*.so.*' -exec chmod +x '{}' \;
	
	# Copy interpolated overlay to target dir, excluding .template file
	rsync -ac --exclude='*.template' "$TMP_DIR/" "$TARGET_DIR"
	
	# Delete temporary directory
	rm -Rf "$TMP_DIR"
}
