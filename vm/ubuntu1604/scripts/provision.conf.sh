#!/bin/bash
#
# Project Factory VM Provisioning Configuration
# By Fabien CRESPEL <fabien@crespel.net>
#

# Project Factory repo
PF_REPO_RELEASES_ENABLED="0"
PF_REPO_RELEASES_LIST="deb https://forge.crespel.me/repos/apt/project-factory-releases/ ubuntu1604 main"
PF_REPO_SNAPSHOTS_ENABLED="1"
PF_REPO_SNAPSHOTS_LIST="deb https://forge.crespel.me/repos/apt/project-factory-snapshots/ ubuntu1604 main"

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
