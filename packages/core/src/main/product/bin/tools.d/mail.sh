#!/bin/bash
#
# Mail template sending script.
# By Fabien CRESPEL <fabien@crespel.net>
#

# Shared routines
SCRIPT_DIR=`dirname "$0"`
. "$SCRIPT_DIR/../loadenv.sh"

# Script variables
USER_UID="$1"
TEMPLATE_FILE="$2"
MAIL_SUBJECT="$3"
MAIL_FROM="noreply@$PRODUCT_DOMAIN"
LDAP_USER_RDN_ATTR="@{ldap.user.rdn.attr}"
LDAP_USER_FIRSTNAME_ATTR="@{ldap.user.firstname.attr}"
LDAP_USER_LASTNAME_ATTR="@{ldap.user.lastname.attr}"
LDAP_USER_MAIL_ATTR="@{ldap.user.mail.attr}"

# Check arguments
if [ -z "$USER_UID" -o -z "$TEMPLATE_FILE" -o -z "$MAIL_SUBJECT" ]; then
	echo "Usage: $0 <username> <mail template> <mail subject>"
	exit 1
fi
if [ ! -e "$TEMPLATE_FILE" ]; then
	echo "Template file '$TEMPLATE_FILE' does not exist"
	exit 1
fi
if ! type -t ldap_getattr >/dev/null; then
	echo "Missing 'ldap_getattr' function, please install the '@{package.prefix}-system-ldap' package first"
	exit 1
fi

# Get user attributes
USER_FIRSTNAME=`ldap_getattr "($LDAP_USER_RDN_ATTR=$USER_UID)" $LDAP_USER_FIRSTNAME_ATTR`
USER_LASTNAME=`ldap_getattr "($LDAP_USER_RDN_ATTR=$USER_UID)" $LDAP_USER_LASTNAME_ATTR`
USER_FULLNAME=`echo $USER_FIRSTNAME $USER_LASTNAME`
USER_MAIL=`ldap_getattr "($LDAP_USER_RDN_ATTR=$USER_UID)" $LDAP_USER_MAIL_ATTR`
if [ -z "$USER_MAIL" ]; then
	echo "Could not find email address for user '$USER_UID'"
	exit 1
fi

echo "Sending mail to $USER_MAIL ..."
interpolatetemplate "$TEMPLATE_FILE" | mail -s "$MAIL_SUBJECT" -r "$MAIL_FROM" "$USER_MAIL"
