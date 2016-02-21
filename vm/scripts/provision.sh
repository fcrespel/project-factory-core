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

# Install EPEL repository
echo
echo "Installing EPEL repository ..."
if ! rpm -q "$EPEL_REPO_PKG" >/dev/null && ! yum -y -q -e 0 install "$EPEL_REPO_URL"; then
	echo "Failed to install EPEL repository, please ensure that the VM has internet access."
	echo "You may run 'vagrant provision' to retry."
	exit 1
fi

# Install PUIAS repository
echo "Installing PUIAS repository ..."
if [ ! -e "$PUIAS_KEY_FILE" ] && ! wget -q -O "$PUIAS_KEY_FILE" "$PUIAS_KEY_URL"; then
	echo "Failed to install PUIAS GPG key, please ensure that the VM has internet access."
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
hostname "$PF_DOMAIN"
if ! grep -q "$PF_DOMAIN" "/etc/sysconfig/network"; then
    sed -i "s#^HOSTNAME=.*#HOSTNAME=$PF_DOMAIN#g" "/etc/sysconfig/network"
fi
if ! grep -q "$PF_DOMAIN" "/etc/hosts"; then
	echo "127.0.0.2   $PF_DOMAIN" >> "/etc/hosts"
fi

# Configure resolv.conf (IPv6 bug with DNS resolving)
echo "Configuring resolv.conf ..."
if ! grep -q "options single-request-reopen" "/etc/resolv.conf"; then
	echo "options single-request-reopen" >> "/etc/resolv.conf"
fi

# Configure mod_ssl
echo "Configuring mod_ssl ..."
if ! grep -q "^ServerName" "/etc/httpd/conf.d/ssl.conf"; then
	sed -i '
/^#ServerName www\.example\.com:443/ a\
ServerName localhost
' "/etc/httpd/conf.d/ssl.conf"
fi

# Configure mod_auth_cas
echo "Configuring mod_auth_cas ..."
if grep -q "^\s*LoadModule" "/etc/httpd/conf.d/auth_cas.conf"; then
	sed -ri 's/^(\s*)LoadModule/#\1LoadModule/g' "/etc/httpd/conf.d/auth_cas.conf"
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
chkconfig iptables off && service iptables stop > /dev/null
chkconfig ip6tables off && service ip6tables stop > /dev/null
chkconfig httpd on && service httpd restart > /dev/null

# Show IP addresses
echo
echo "Available IP addresses:"
ip -4 addr show | grep inet | grep -v '127\.0\.0\.1' | awk '{ print "\t" $NF ":\t" $2 }'

# Show platform users and passwords
echo
echo "Platform users:"
( . "$PF_ROOT/bin/loadenv.sh" && echo -e "\troot:\t$ROOT_PASSWORD" )
( . "$PF_ROOT/bin/loadenv.sh" && echo -e "\tbot:\t$BOT_PASSWORD" )

# Show main URL
echo
echo "You may now browse to http://$PF_DOMAIN to get started!"
