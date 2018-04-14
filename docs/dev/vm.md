---
layout: page
title: Vagrant VM
---

**IMPORTANT:** these instructions apply for a **development/test** setup.
For a production platform, please refer to the [requirements](../install/reqs.html) and [packages installation](../install/packages.html) pages.

- Table of contents
{:toc}

## Prerequisites

-   The host machine must be running a **64-bit** OS with **more than 4 GB RAM free**.
-   **VirtualBox** and **Vagrant** must be installed (see [Development environment](env.html)).
-   **Project Factory sources** must be cloned locally (see [Development environment](env.html)).
-   If a **proxy** is required to connect to the Internet:
    -   Add a proxy exception for `dev.project-factory.fr` (local VM hostname).
    -   In the `project-factory-core` directory, create a `vm/<distro>/scripts/provision.local.sh` file (with Linux/Unix line endings) containing:

            PROXY_HOST="<your proxy host>"
            PROXY_PORT="<your proxy port>"

## Startup/access/shutdown

### Starting the VM

-   Open a **command line prompt**.
-   Change to the `vm/<distro>` directory of the `project-factory-core` repository (e.g. `vm/centos7`).
-   Execute the command: `vagrant up`

Vagrant will execute the following steps automatically:

-   **Download** a pre-built **VM template** from the Internet (the first time only).
-   **Start** and configure its **host-only network** with a predefined IP address.
-   Configure required **software repositories**.
-   Install base **Project Factory packages**.
-   **Configure** the machine (hostname, firewall, services, etc.)
-   Display **usernames/passwords** to access the platform.

If an error occurs during these steps, you may execute `vagrant provision` to try again.

The default VM settings are:

-   **RAM:** 4 GB
-   **IP address:** 192.168.56.57
-   **Hostname:** dev.project-factory.fr
-   **Shared folder:** `/opt/projectfactory/src` (parent directory of `project-factory-core`)
-   **Project Factory packages**:
    -   dev-projectfactory-core
    -   dev-projectfactory-devel
    -   dev-projectfactory-system-httpd
    -   dev-projectfactory-system-ldap
    -   dev-projectfactory-system-maven3
    -   dev-projectfactory-system-mysql
    -   dev-projectfactory-system-php
    -   dev-projectfactory-system-ruby
    -   dev-projectfactory-system-tomcat
    -   dev-projectfactory-service-cas
    -   dev-projectfactory-service-portal
    -   dev-projectfactory-admin-phpmyadmin
    -   dev-projectfactory-admin-phpldapadmin

You may customize the packages installed during provisioning by redefining the `PF_PKG_EXTRA` variable from `provision.conf.sh` in the `provision.local.sh` file.

### Stopping the VM

-   Change to the `vm/<distribution>` directory of the `project-factory-core` repository (e.g. `vm/centos7`).
-   To **save** the current VM state, execute the command: `vagrant suspend`
-   To **stop** the VM gracefully, execute the command: `vagrant halt`
-   To stop and **delete** the VM, execute the command: `vagrant destroy`

### Accessing the VM

-   **HTTP/HTTPS**: browse to <http://dev.project-factory.fr>
-   **SSH**: execute the command: `vagrant ssh` or connect directly with a SSH client (user `root`, password displayed at the end of provisioning).

## Development

The VM is preconfigured to ease development:

-   The **source directories** from the host are available in `/opt/projectfactory/src` (parent directory of `project-factory-core`).
-   **Maven** is installed and configured.
-   The **iT-Toolbox OSS Snapshots repository** is configured.
-   A **local repository** is refreshed every 5 minutes and contains all RPM/DEB packages locally installed by Maven.

**IMPORTANT:** package building must be done with system user `pf`, and installation with system user `root`.

Using SSH to connect to the VM, it is therefore possible to build **Project Factory** entirely, or only certain packages in development.
For example, to build and install the SVN 3.4.0-1-SNAPSHOT package:

    sudo su - pf
    cd /opt/projectfactory/src
    cd packages/services/svn
    mvn clean install
    exit

    sudo su -
    yum install /opt/projectfactory/dev/data/system/maven/repository/fr/project-factory/packages/services/svn/3.4.0-1-SNAPSHOT/svn-3.4.0-1-SNAPSHOT-dev-projectfactory-el7-x86_64.rpm

**NOTICE:** as 2 active repositories may contain the same packages (local and iT-Toolbox OSS), only the most recent dependencies will be installed.

**IMPORTANT**: make sure to use `-` in the `sudo` user switch command (as shown above) so that environment variables are properly set.
Failure to do so will cause certain commands like `mvn` not to work when using system user `pf`.
