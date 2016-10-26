#!/bin/bash
#
# Project Factory - Core Configuration
#

# DO NOT MODIFY THIS FILE
# Use @{product.data}/system/core/config.sh for local values

# Product configuration
PRODUCT_NAME="@{product.name}"
PRODUCT_ID="@{product.id}"
PRODUCT_ROOT="@{product.root}"
PRODUCT_APP="@{product.app}"
PRODUCT_BACKUP="@{product.backup}"
PRODUCT_BIN="@{product.bin}"
PRODUCT_DATA="@{product.data}"
PRODUCT_LOG="@{product.log}"
PRODUCT_TMP="@{product.tmp}"
PRODUCT_DOMAIN="@{product.domain}"
PRODUCT_DOMAIN_ALIAS="@{product.domain.alias}"
PRODUCT_THEME="@{product.theme}"
PRODUCT_USER="@{product.user}"
PRODUCT_GROUP="@{product.group}"
PRODUCT_GROUP_ADMINS="@{product.group.admins}"
PRODUCT_GROUP_SUPERVISORS="@{product.group.supervisors}"
PRODUCT_GROUP_USERS="@{product.group.users}"

# Proxy configuration
PROXY_HOST="@{proxy.host}"
PROXY_PORT="@{proxy.port}"

# Platform users
ROOT_USER="@{root.user}"
BOT_USER="@{bot.user}"
