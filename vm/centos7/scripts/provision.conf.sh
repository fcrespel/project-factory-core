#!/bin/bash
#
# Project Factory VM Provisioning Configuration
# By Fabien CRESPEL <fabien@crespel.net>
#

# Repo config
REPO_PKG="https://dl.fedoraproject.org/pub/epel/7/x86_64/Packages/e/epel-release-7-11.noarch.rpm https://rpms.remirepo.net/enterprise/remi-release-7.rpm https://repo.mysql.com/mysql57-community-release-el7.rpm https://rpm.nodesource.com/pub_8.x/el/7/x86_64/nodesource-release-el7-1.noarch.rpm"

# iT-Toolbox OSS repo config
ITTB_OSS_REPO_RELEASES_ENABLED="0"
ITTB_OSS_REPO_SNAPSHOTS_ENABLED="1"

# Project Factory config
PF_PKG_PREFIX="dev-projectfactory"
PF_PKG_CORE="$PF_PKG_PREFIX-core"
PF_PKG_DEFAULT="$PF_PKG_PREFIX-system-ldap $PF_PKG_PREFIX-service-portal"
PF_PKG_EXTRA="$PF_PKG_PREFIX-service-cas $PF_PKG_PREFIX-admin-phpmyadmin $PF_PKG_PREFIX-admin-phpldapadmin"
PF_USER="pf"
PF_ROOT="/opt/projectfactory/dev"

# Proxy config
PROXY_HOST="" # <- Configure in provision.local.sh
PROXY_PORT="" # <- Configure in provision.local.sh
