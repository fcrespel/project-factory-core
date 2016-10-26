#!/bin/bash
#
# Project Factory - Core Functions
# By Fabien CRESPEL <fabien@crespel.net>
#

# Terminal colors
COLOR_RED="\\033[0;31m"
COLOR_GREEN="\\033[0;32m"
COLOR_BLUE="\\033[0;34m"
COLOR_RESET="\\033[0m"

# Print error/success/info message in color
function printerror
{
	echo -e "${COLOR_RED}$1${COLOR_RESET}"
}
function printsuccess
{
	echo -e "${COLOR_GREEN}$1${COLOR_RESET}"
}
function printinfo
{
	echo -e "${COLOR_BLUE}$1${COLOR_RESET}"
}

# Store a variable in a configuration file (or choose it automatically if undefined)
function storevar
{
	local VAR="$1"
	local VALUE="$2"
	local CONFIG_FILE="$3"
	if [ -z "$CONFIG_FILE" ]; then
		if [ -z "$CORE_DATA_DIR" ]; then
			printerror "ERROR: core data directory is not defined or is empty"
			return 1
		fi
		if [[ $VAR =~ PASSWORD || $VAR =~ KEY ]]; then
			CONFIG_FILE="$CORE_DATA_DIR/passwd.sh"
		else
			CONFIG_FILE="$CORE_DATA_DIR/config.sh"
		fi
	fi
	export $VAR="$VALUE"
	if [ ! -e "$CONFIG_FILE" ]; then
		touch "$CONFIG_FILE"
	fi
	if grep -q "$VAR=" "$CONFIG_FILE"; then
		sed -i "s#^$VAR=.*#$VAR=\"$VALUE\"#g" "$CONFIG_FILE"
	else
		echo "$VAR=\"$VALUE\"" >> "$CONFIG_FILE"
	fi
}

# Add a value to a variable in a configuration file
function addvar
{
	local VAR="$1"
	local VALUE="$2"
	local CONFIG_FILE="$3"
	if ! containsvar "$VAR" "$VALUE"; then
		local VALUES="${!VAR}"
		VALUES=`echo "$VALUES $VALUE" | sed -r 's#^\s+|\s+$##g'`
		storevar "$VAR" "$VALUES" "$CONFIG_FILE"
	fi
}

# Remove a value from a variable in a configuration file
function removevar
{
	local VAR="$1"
	local VALUE="$2"
	local CONFIG_FILE="$3"
	if containsvar "$VAR" "$VALUE"; then
		local VALUES="${!VAR}"
		VALUES=`echo "$VALUES" | sed -r "s#(^|\\s)$VALUE(\\s|\$)# #g" | sed -r 's#^\s+|\s+$##g'`
		storevar "$VAR" "$VALUES" "$CONFIG_FILE"
	fi
}

# Check if a variable contains a value
function containsvar
{
	local VAR="$1"
	local VALUE="$2"
	local VALUES="${!VAR}"
	echo "$VALUES" | grep -q -E "(^|\\s)$VALUE(\\s|\$)"
}

# Generate a random password
function genpassword
{
	local LENGTH="$1"
	if [ -z "$LENGTH" ]; then
		LENGTH=16
	fi
	cat /dev/urandom | tr -dc A-Za-z0-9 | head -c$LENGTH
}

# Ensure a password exists or generate one on-the-fly
function ensurepassword
{
	local VAR="$1"
	local LENGTH="$2"
	local VALUE="${!VAR}"
	if [ -z "$VALUE" ]; then
		VALUE=`genpassword $LENGTH`
		storevar "$VAR" "$VALUE"
	fi
}

# Enable and start a service
function enableservice
{
	local SERVICE="$1"
	local ACTION="$2"
	local RET=0
	if [ -e "@{system.init}/$SERVICE" ]; then
		[ -x "@{system.init}/$SERVICE" ] || chmod +x "@{system.init}/$SERVICE"
		if containsvar "SERVICES_DISABLED" "$SERVICE"; then
			if [ "$ACTION" = "force" ]; then
				removevar "SERVICES_DISABLED" "$SERVICE"
			else
				printerror "WARNING: ignoring disabled service '$SERVICE'"
				return $RET
			fi
		fi
		/usr/lib/lsb/install_initd "@{system.init}/$SERVICE"
		if ! service $SERVICE status > /dev/null 2>&1; then
			if ! service $SERVICE start > /dev/null; then
				printerror "ERROR: failed to start service '$SERVICE'"
				RET=1
			fi
		else
			if [ "$ACTION" = "reload" ]; then
				if ! service $SERVICE force-reload > /dev/null; then
					printerror "ERROR: failed to reload service '$SERVICE'"
					RET=1
				fi
			elif [ "$ACTION" = "restart" ]; then
				if ! service $SERVICE restart > /dev/null; then
					printerror "ERROR: failed to restart service '$SERVICE'"
					RET=1
				fi
			fi
		fi
	else
		printerror "ERROR: failed to find service '$SERVICE'"
		RET=2
	fi
	return $RET
}

# Start a service
function startservice
{
	local SERVICE="$1"
	local ACTION="$2"
	local RET=0
	if [ -e "@{system.init}/$SERVICE" ]; then
		[ -x "@{system.init}/$SERVICE" ] || chmod +x "@{system.init}/$SERVICE"
		if containsvar "SERVICES_DISABLED" "$SERVICE"; then
			if [ "$ACTION" != "force" ]; then
				printerror "WARNING: ignoring disabled service '$SERVICE'"
				return $RET
			fi
		fi
		if ! service $SERVICE status > /dev/null 2>&1; then
			if ! service $SERVICE start > /dev/null; then
				printerror "ERROR: failed to start service '$SERVICE'"
				RET=1
			fi
		fi
	else
		printerror "ERROR: failed to find service '$SERVICE'"
		RET=2
	fi
	return $RET
}

# Query the status of a service
function statusservice
{
	local SERVICE="$1"
	local RET=0
	if [ -e "@{system.init}/$SERVICE" ]; then
		[ -x "@{system.init}/$SERVICE" ] || chmod +x "@{system.init}/$SERVICE"
		service $SERVICE status
		RET=$?
	else
		printerror "ERROR: failed to find service '$SERVICE'"
		RET=2
	fi
	return $RET
}

# Reload a service
function reloadservice
{
	local SERVICE="$1"
	local ACTION="$2"
	local RET=0
	if [ -e "@{system.init}/$SERVICE" ]; then
		[ -x "@{system.init}/$SERVICE" ] || chmod +x "@{system.init}/$SERVICE"
		if containsvar "SERVICES_DISABLED" "$SERVICE"; then
			if [ "$ACTION" != "force" ]; then
				printerror "WARNING: ignoring disabled service '$SERVICE'"
				return $RET
			fi
		fi
		if service $SERVICE status > /dev/null 2>&1; then
			if ! service $SERVICE force-reload > /dev/null; then
				printerror "ERROR: failed to reload service '$SERVICE'"
				RET=1
			fi
		fi
	fi
	return $RET
}

# Stop a service
function stopservice
{
	local SERVICE="$1"
	local RET=0
	if [ -e "@{system.init}/$SERVICE" ]; then
		[ -x "@{system.init}/$SERVICE" ] || chmod +x "@{system.init}/$SERVICE"
		if service $SERVICE status > /dev/null 2>&1; then
			if ! service $SERVICE stop > /dev/null; then
				printerror "ERROR: failed to stop service '$SERVICE'"
				RET=1
			fi
		fi
	fi
	return $RET
}

# Stop and disable a service
function disableservice
{
	local SERVICE="$1"
	local ACTION="$2"
	local RET=0
	if [ -e "@{system.init}/$SERVICE" ]; then
		[ -x "@{system.init}/$SERVICE" ] || chmod +x "@{system.init}/$SERVICE"
		if [ "$ACTION" = "force" ]; then
			addvar "SERVICES_DISABLED" "$SERVICE"
		fi
		if service $SERVICE status > /dev/null 2>&1; then
			if ! service $SERVICE stop > /dev/null; then
				printerror "ERROR: failed to stop service '$SERVICE'"
				RET=1
			fi
		fi
		/usr/lib/lsb/remove_initd "@{system.init}/$SERVICE"
	fi
	return $RET
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

# Interpolate all %{PLACEHOLDERS} in a file and overwrite it if no errors occurred
function interpolatetemplate_inplace
{
	local TEMPLATE_FILE="$1"
	local TEMPLATE_TMP=`mktemp --tmpdir="$PRODUCT_TMP"`
	if interpolatetemplate "$TEMPLATE_FILE" > "$TEMPLATE_TMP"; then
		cat "$TEMPLATE_TMP" > "$TEMPLATE_FILE"
	fi
	rm -f $TEMPLATE_TMP
}

# Run all cron scripts in a directory
function run_cron_scripts()
{
	local DIR="$1"
	if [ -n "$DIR" -a -d "$DIR" ]; then
		find "$DIR" -mindepth 1 -maxdepth 1 | while read FILE; do
			[ -d "$FILE" ] && continue
			[ -x "$FILE" ] || continue
			case `basename "$FILE"` in
				.svn)		continue ;;
				.flag)		continue ;;
				*.rpm*)		continue ;;
				*.dpkg*)	continue ;;
				*.swp)		continue ;;
				*.swap)		continue ;;
				*.bak)		continue ;;
				*.orig)		continue ;;
				*,v)		continue ;;
				\#*)		continue ;;
				*~)			continue ;;
			esac
			
			# jobs.deny prevents specific files from being executed
			if [ -r "$DIR/jobs.deny" ]; then
				grep -q "^$(basename $FILE)$" "$DIR/jobs.deny" && continue
			fi
			
			# jobs.allow prohibits all non-named jobs from being run
			if [ -r "$DIR/jobs.allow" ]; then
				grep -q "^$(basename $FILE)$" "$DIR/jobs.allow" || continue
			fi
			
			if [ ! -e "$FILE.lock" ]; then
				if touch "$FILE.lock"; then
					$FILE 2>&1 | awk -v "progname=$FILE" \
										'progname {
											print progname ":\n"
											progname="";
										}
										{ print; }'
					rm -f "$FILE.lock"
				fi
			fi
		done
	fi
}

# Create a Java trust store
function create_truststore
{
	local TRUSTSTORE="$1"
	local TRUSTSTORE_USER="$2"
	local TRUSTSTORE_GROUP="$3"
	local TRUSTSTORE_IMPORT="$4"
	local TRUSTSTORE_PASSWORD="changeit"
	local CACERT="$PRODUCT_APP/system/httpd/ssl/cacert.pem"
	
	# Delete old CA certificate
	if [ -e "$TRUSTSTORE" -a -e "$CACERT" ]; then
		keytool -delete -alias "$PRODUCT_DOMAIN" -keystore "$TRUSTSTORE" -storepass "$TRUSTSTORE_PASSWORD" > /dev/null 2>&1
	fi
	
	# Import current CA certificate
	if [ -e "$CACERT" ]; then
		if ! keytool -import -noprompt -file "$CACERT" -alias "$PRODUCT_DOMAIN" -keystore "$TRUSTSTORE" -storepass "$TRUSTSTORE_PASSWORD" > /dev/null 2>&1; then
			printerror "ERROR: failed to import platform certificate to trust store"
		fi
	fi
	
	# Import additional trust store contents
	if [ -e "$TRUSTSTORE" -a -n "$TRUSTSTORE_IMPORT" -a -e "$TRUSTSTORE_IMPORT" ]; then
		if ! keytool -importkeystore -noprompt -srckeystore "$TRUSTSTORE_IMPORT" -srcstorepass "changeit" -destkeystore "$TRUSTSTORE" -deststorepass "$TRUSTSTORE_PASSWORD" > /dev/null 2>&1; then
			printerror "ERROR: failed to import additional certificates to trust store"
		fi
	fi
	
	# Change owner
	if [ -e "$TRUSTSTORE" -a -n "$TRUSTSTORE_USER" -a -n "$TRUSTSTORE_GROUP" ]; then
		chown $TRUSTSTORE_USER:$TRUSTSTORE_GROUP "$TRUSTSTORE"
	fi
}

# List installed packages
function listpackages
{
	local PACKAGES="$1"
	if which dpkg > /dev/null 2>&1; then
		dpkg -l | grep "$PACKAGES" | sort
	elif which rpm > /dev/null 2>&1; then
		rpm -qa | grep "$PACKAGES" | sort
	else
		printerror "ERROR: failed to detect package manager"
		return 1
	fi
}

# Install a package if not already installed
function installpackage
{
	local PACKAGE="$1"
	local RET=0
	if listpackages | grep -q "$PACKAGE"; then
		echo "Package '$PACKAGE' is already installed"
	else
		if which apt-get > /dev/null 2>&1; then
			DEBIAN_FRONTEND="noninteractive" apt-get -q -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" --allow-unauthenticated --no-install-recommends install "$PACKAGE"
			RET=$?
		elif which yum > /dev/null 2>&1; then
			yum -y -e 0 install "$PACKAGE"
			RET=$?
		elif which zypper > /dev/null 2>&1; then
			zypper -n install -l "$PACKAGE"
			RET=$?
		else
			printerror "ERROR: failed to detect package manager"
			RET=1
		fi
		if [ $RET -eq 0 ]; then
			printsuccess "Package '$PACKAGE' successfully installed"
		else
			printerror "ERROR: failed to install package '$PACKAGE'"
		fi
	fi
	return $RET
}

# Update an installed package
function updatepackage
{
	local PACKAGE="$1"
	local RET=0
	if ! listpackages | grep -q "$PACKAGE"; then
		printerror "ERROR: package '$PACKAGE' is not installed"
		RET=1
	else
		if which apt-get > /dev/null 2>&1; then
			DEBIAN_FRONTEND="noninteractive" apt-get -q -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" --allow-unauthenticated --no-install-recommends install --only-upgrade "$PACKAGE"
			RET=$?
		elif which yum > /dev/null 2>&1; then
			yum -y -e 0 update "$PACKAGE"
			RET=$?
		elif which zypper > /dev/null 2>&1; then
			zypper -n update -l "$PACKAGE"
			RET=$?
		else
			printerror "ERROR: failed to detect package manager"
			RET=1
		fi
		if [ $RET -eq 0 ]; then
			printsuccess "Package '$PACKAGE' successfully updated"
		else
			printerror "ERROR: failed to update package '$PACKAGE'"
		fi
	fi
	return $RET
}

# Remove an installed package
function removepackage
{
	local PACKAGE="$1"
	local RET=0
	if ! listpackages | grep -q "$PACKAGE"; then
		echo "Package '$PACKAGE' is not installed"
	else
		if which apt-get > /dev/null 2>&1; then
			DEBIAN_FRONTEND="noninteractive" apt-get -q -y remove "$PACKAGE"
			RET=$?
		elif which yum > /dev/null 2>&1; then
			yum -y -e 0 erase "$PACKAGE"
			RET=$?
		elif which zypper > /dev/null 2>&1; then
			zypper -n remove "$PACKAGE"
			RET=$?
		else
			printerror "ERROR: failed to detect package manager"
			RET=1
		fi
		if [ $RET -eq 0 ]; then
			printsuccess "Package '$PACKAGE' successfully removed"
		else
			printerror "ERROR: failed to remove package '$PACKAGE'"
		fi
	fi
	return $RET
}
