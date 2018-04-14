---
layout: page
title: Command-line administration tool
---

A command-line platform administration tool is available since **Project Factory** version 3.3.

As `root`, execute the `${PRODUCT_ID}-admin` command, for example:

    pf-admin <command name> [command options ...]

Available commands can be found in the `${PRODUCT_BIN}/tools.d` directory of the platform.
You may add custom scripts to make them available via the admin tool.

**Commands list:**

- Table of contents
{:toc}

### Backup

    pf-admin backup <service name>

Perform immediate backup of the requested service (e.g. `mysql`, `redmine`, etc.)
If the `<service name>` argument is missing, a list of available services is displayed.

### Bulk

    pf-admin bulk <script file> <args file>

Call a script in bulk with the arguments specified in the file (1 line = 1 call of the script with these arguments).

### Config

    pf-admin config get <key>
    pf-admin <set|add|remove> <key> <value>

Get or set the value of a configuration key.
The `add` and `remove` actions can be used to add/remove values from a space-separated list.

### Mail

    pf-admin mail <username> <mail template> <mail subject>

Send an email to a platform user from a template file. This file may contain the following placeholders:

-   `%{USER_UID}`: user name
-   `%{USER_FIRSTNAME}`: first name
-   `%{USER_LASTNAME}`: last name
-   `%{USER_FULLNAME}`: first name last name
-   `%{USER_MAIL}`: email address

### Maintenance

    pf-admin maintenance <enable|disable> [service name]

Enable or disable maintenance mode for the requested service, or for the whole platform if no service is specified.
Maintenance mode will cause the HTTP server to return a 503 response code.

### Package

    pf-admin package list [system|admin|service]
    pf-admin package <install|update|remove> <system|admin|service> <package name>

Manage platform packages. See [Packages installation](../install/packages.html).

### Portal

    pf-admin portal theme <new theme>

Change the portal and platform theme.
If the `<new theme>` argument is missing, a list of available themes is displayed.

### Rename user

    pf-admin rename-user <source username> <target username>

Rename a user name in all supported services of the platform.

### Restore

    pf-admin restore <service name>

Restore data from a backup for the requested service.
If the `<service name>` argument is missing, a list of available services is displayed.

### Service

    pf-admin service <enable|start|status|reload|stop|disable> <service name>

Manage platform services.
If the `<service name>` argument is missing, a list of available services is displayed.

### Update truststore

    pf-admin update-truststore <truststore.jks|all> [import.jks]

Update the requested Java trust store or all trust stores with the current CA certificate.
An existing trust store may be specified to be imported in addition to the platform CA.
