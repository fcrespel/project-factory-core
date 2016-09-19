#!/bin/sh
#
# Project Factory VM Provisioning Configuration
# By Fabien CRESPEL <fabien@crespel.net>
#

# EPEL repo config
EPEL_REPO_PKG="http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm"

# PUIAS repo config
PUIAS_KEY_URL="http://puias.math.ias.edu/data/puias/6/x86_64/os/RPM-GPG-KEY-puias"
PUIAS_KEY_FILE="/etc/pki/rpm-gpg/RPM-GPG-KEY-puias"

# iT-Toolbox OSS repo config
ITTB_OSS_REPO_RELEASES_ENABLED="0"
ITTB_OSS_REPO_SNAPSHOTS_ENABLED="1"

# Project Factory config
PF_PKG_PREFIX="dev-projectfactory"
PF_PKG_DEFAULT="$PF_PKG_PREFIX-system-ldap $PF_PKG_PREFIX-service-portal"
PF_PKG_EXTRA="$PF_PKG_PREFIX-service-cas $PF_PKG_PREFIX-admin-phpmyadmin $PF_PKG_PREFIX-admin-phpldapadmin"
PF_USER="pf"
PF_ROOT="/opt/projectfactory/dev"

# Proxy config
PROXY_HOST="" # <- Configure in provision.local.sh
PROXY_PORT="" # <- Configure in provision.local.sh
