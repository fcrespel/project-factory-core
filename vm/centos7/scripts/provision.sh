#!/bin/sh
#
# Project Factory VM Provisioning Script
# By Fabien CRESPEL <fabien@crespel.net>
#

# Load external files
. "/vagrant/scripts/provision.functions.sh"
. "/vagrant/scripts/provision.conf.sh"
[ -f "/vagrant/scripts/provision.local.sh" ] && . "/vagrant/scripts/provision.local.sh"

# Configure proxy
PF_PROXY_HOST="$PROXY_HOST"
PF_PROXY_PORT="$PROXY_PORT"
if [ -n "$PROXY_HOST" -a -n "$PROXY_PORT" ] && [ "$PROXY_PORT" -gt 0 ]; then
	export HTTP_PROXY="http://$PROXY_HOST:$PROXY_PORT"
	export http_proxy="http://$PROXY_HOST:$PROXY_PORT"
	export HTTPS_PROXY="http://$PROXY_HOST:$PROXY_PORT"
	export https_proxy="http://$PROXY_HOST:$PROXY_PORT"
	export FTP_PROXY="http://$PROXY_HOST:$PROXY_PORT"
	export ftp_proxy="http://$PROXY_HOST:$PROXY_PORT"
fi

# Install prerequisites
echo
echo "Installing prerequisites ..."
if ! installpackages rsync vim-enhanced; then
	echo "Failed to install prerequisites, please ensure that the VM has internet access."
	echo "You may run 'vagrant provision' to retry."
	exit 1
fi

# Install EPEL repository
echo "Installing EPEL repository ..."
if ! installpackages "$EPEL_REPO_PKG"; then
	echo "Failed to install EPEL repository, please ensure that the VM has internet access."
	echo "You may run 'vagrant provision' to retry."
	exit 1
fi

# Install Overlay
echo "Installing Overlay ..."
if ! installoverlay "/vagrant/overlay" "/"; then
	echo "Failed to install overlay"
	echo "You may run 'vagrant provision' to retry."
	exit 1
fi

# Install Project Factory core package
echo "Installing Project Factory core package ..."
if ! installpackages "$PF_PKG_PREFIX-core"; then
	echo "Failed to install Project Factory core package"
	echo "You may run 'vagrant provision' to retry."
	exit 1
fi

# Store proxy configuration
( . "$PF_ROOT/bin/loadenv.sh" && storevar PROXY_HOST "$PF_PROXY_HOST" )
( . "$PF_ROOT/bin/loadenv.sh" && storevar PROXY_PORT "$PF_PROXY_PORT" )

# Install Project Factory default packages
echo "Installing Project Factory default packages ..."
if ! installpackages "$PF_PKG_DEFAULT"; then
	echo "Failed to install Project Factory default packages"
	echo "You may run 'vagrant provision' to retry."
	exit 1
fi

# Install Project Factory extra packages
echo "Installing Project Factory extra packages ..."
if ! installpackages "$PF_PKG_EXTRA"; then
	echo "Failed to install Project Factory extra packages"
	echo "You may run 'vagrant provision' to retry."
	exit 1
fi

# Install Project Factory devel package
echo "Installing Project Factory devel package ..."
if ! installpackages "$PF_PKG_PREFIX-devel"; then
	echo "Failed to install Project Factory devel package"
	echo "You may run 'vagrant provision' to retry."
	exit 1
fi

# Configure root password
echo
echo "Configuring root password ..."
( . "$PF_ROOT/bin/loadenv.sh" && echo "root:$ROOT_PASSWORD" | chpasswd )

# Configure hostname
PF_DOMAIN=`. "$PF_ROOT/bin/loadenv.sh" && echo $PRODUCT_DOMAIN`
echo "Configuring hostname ($PF_DOMAIN) ..."
hostnamectl set-hostname "$PF_DOMAIN"
if ! grep -q "$PF_DOMAIN" "/etc/hosts"; then
	echo "127.0.0.2   $PF_DOMAIN" >> "/etc/hosts"
fi

# Configure motd
echo "Configuring motd ..."
sed -i 's#PrintMotd no#PrintMotd yes#g' "/etc/ssh/sshd_config"

# Configure mod_ssl
echo "Configuring mod_ssl ..."
if ! grep -q "^ServerName" "/etc/httpd/conf.d/ssl.conf"; then
	sed -i '
/^#ServerName www\.example\.com:443/ a\
ServerName localhost
' "/etc/httpd/conf.d/ssl.conf"
fi

# Configure Maven proxy
echo "Configuring Maven proxy ..."
sed -i '/^\s*<proxies>/,/<\/proxies>/d' "$PF_ROOT/data/system/maven/settings.xml"
if [ -n "$PROXY_HOST" -a -n "$PROXY_PORT" ] && [ "$PROXY_PORT" -gt 0 ]; then
	sed -i '
/^\s*<profiles>/ i\
\t<proxies>\n\t\t<proxy>\n\t\t\t<active>true</active>\n\t\t\t<protocol>http</protocol>\n\t\t\t<host>'$PROXY_HOST'</host>\n\t\t\t<port>'$PROXY_PORT'</port>\n\t\t\t<nonProxyHosts>'$PF_DOMAIN'</nonProxyHosts>\n\t\t</proxy>\n\t\t<proxy>\n\t\t\t<active>true</active>\n\t\t\t<protocol>https</protocol>\n\t\t\t<host>'$PROXY_HOST'</host>\n\t\t\t<port>'$PROXY_PORT'</port>\n\t\t\t<nonProxyHosts>'$PF_DOMAIN'</nonProxyHosts>\n\t\t</proxy>\n\t</proxies>
' "$PF_ROOT/data/system/maven/settings.xml"
fi

# Configure services
echo "Configuring services ..."
systemctl disable firewalld && systemctl stop firewalld > /dev/null
systemctl enable httpd && systemctl start httpd > /dev/null
systemctl reload sshd > /dev/null

# Show welcome info
echo
echo "==============================================================================="
echo "Welcome to your Project Factory server"
echo "More info: http://www.project-factory.fr"

# Show IP addresses
echo
echo "Available IP addresses:"
ip -4 addr show | grep inet | grep -v '127\.0\.0\.1' | awk '{ print "\t" $NF ":\t" $2 }'

# Show platform users and passwords
echo
echo "Platform users:"
( . "$PF_ROOT/bin/loadenv.sh" && echo -e "\troot:\t$ROOT_PASSWORD" )
( . "$PF_ROOT/bin/loadenv.sh" && echo -e "\tbot:\t$BOT_PASSWORD" )

# Show platform URL
echo
echo "Platform URL: http://$PF_DOMAIN"
