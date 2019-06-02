---
layout: page
title: Requirements
---

**IMPORTANT:** these instructions apply for a **production** setup.
For a test/development platform, you should rather use the [Vagrant VM](../dev/vm.html).

- Table of contents
{:toc}

## Machine

The configuration of the physical or virtual machine hosting the **Project Factory** platform strongly depends on the expected usage (number of concurrent users, installed services, amount of data produced).

It is recommended to have at least:

-   **CPU:** 2
-   **RAM:** 8 GB
-   **Storage:** 100 GB
    -   System: 20 GB
    -   `product.app` directory: 10 GB
    -   `product.data` directory: 50 GB
    -   `product.log` directory: 10 GB
    -   `product.tmp` directory: 10 GB

## Operating System

**Project Factory** is made to work on **Linux**. Since version 3.1, any distribution based on **RPM** or **DEB** packages can be supported; at this time **Project Factory** was built and tested with:

-   RedHat/CentOS 7
-   Debian 9 (“stretch”)
-   Ubuntu 16.04

If applicable, **SELinux** must be disabled or set to “permissive” mode before starting the installation. To do so:

-   Execute `setenforce 0` to switch to permissive mode immediately.
-   Set `SELINUX=permissive` or `disabled` in the `/etc/selinux/config` file.

If applicable, **AppArmor** must be disabled or set to “complain” mode before installing certain packages (notably MySQL and LDAP). To do so:

-   Disable the MySQL profile:

        ln -sf /etc/apparmor.d/usr.sbin.mysqld /etc/apparmor.d/disable/usr.sbin.mysqld

-   Disable the LDAP profile:

        ln -sf /etc/apparmor.d/usr.sbin.slapd /etc/apparmor.d/disable/usr.sbin.slapd

-   Reload profiles:

        service apparmor reload

Access to **packages repositories** of the distribution and **Project Factory** is also required during installation in order to download dependencies. If no local mirror is setup, an Internet connection will be necessary.

## Package repositories

Before installing **Project Factory** packages, additional **repositories** must be configured on the system.

### RedHat/CentOS 7

-   [**Extra Packages for Enterprise Linux**](http://fedoraproject.org/wiki/EPEL):
    -   Execute this command:

            yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

-   [**Remi repo**](https://blog.remirepo.net/pages/Config-en):
    -   Execute these commands:

            yum install yum-utils https://rpms.remirepo.net/enterprise/remi-release-7.rpm
            yum-config-manager --enable remi-php70

-   [**MySQL**](https://dev.mysql.com/downloads/repo/yum/):
    -   Execute this command:

            yum install https://repo.mysql.com/mysql57-community-release-el7.rpm

-   [**NodeJS**](https://github.com/nodesource/distributions/blob/master/README.md#rpm):
    -   Execute this command:

            curl --silent --location https://rpm.nodesource.com/setup_8.x | sudo bash -

-   [**Yarn**](https://yarnpkg.com/en/docs/install#linux-tab):
    -   Execute this command:

            sudo wget https://dl.yarnpkg.com/rpm/yarn.repo -O /etc/yum.repos.d/yarn.repo

-   **Project Factory Releases**:
    -   Create the `project-factory.repo` file in `/etc/yum.repos.d`:

            [project-factory-releases]
            name=Project Factory Releases
            baseurl=https://forge.crespel.me/repos/yum/project-factory-releases/el7/
            enabled=1
            protect=0
            gpgcheck=1
            gpgkey=https://forge.crespel.me/repos/GPG-KEY-Project-Factory
            sslverify=0
            autorefresh=1
            type=rpm-md

### Debian 9 (“stretch”)

-   [**MySQL**](https://dev.mysql.com/downloads/repo/apt/):
    -   Execute these commands:

            wget http://repo.mysql.com/mysql-apt-config_0.8.9-1_all.deb
            dpkg -i mysql-apt-config_0.8.9-1_all.deb

    -   Choose the MySQL 5.7 repository in the configuration wizard

-   [**NodeJS**](https://github.com/nodesource/distributions/blob/master/README.md#deb):
    -   Execute this command:

            curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -

-   [**Yarn**](https://yarnpkg.com/en/docs/install#linux-tab):
    -   Execute these commands:

            curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
            echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

-   **Project Factory Releases**:
    -   Execute this command:

            wget -qO - https://forge.crespel.me/repos/GPG-KEY-Project-Factory | sudo apt-key add -

    -   Create the `project-factory.list` file in `/etc/apt/sources.list.d`:

            deb https://forge.crespel.me/repos/apt/project-factory-releases/ debian9 main

### Ubuntu 16.04

-   [**OpenJDK PPA**](https://launchpad.net/~openjdk-r/+archive/ubuntu/ppa)
    -   Execute this command:

            add-apt-repository -y ppa:openjdk-r/ppa

-   [**NodeJS**](https://github.com/nodesource/distributions/blob/master/README.md#deb):
    -   Execute this command:

            curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -

-   [**Yarn**](https://yarnpkg.com/en/docs/install#linux-tab):
    -   Execute these commands:

            curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
            echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

-   **Project Factory Releases**:
    -   Execute this command:

            wget -qO - https://forge.crespel.me/repos/GPG-KEY-Project-Factory | sudo apt-key add -

    -   Create the `project-factory.list` file in `/etc/apt/sources.list.d`:

            deb https://forge.crespel.me/repos/apt/project-factory-releases/ ubuntu1604 main

## Firewall

All  “public” services hosted on the **Project Factory** platform are exposed via an Apache reverse proxy.
**Only TCP ports 80 et 443** need to be opened in the machine or network firewall.

All “internal” services listen on the loopback interface (127.0.0.1) and are not accessible from the outside.

**NOTICE:** users with SSH access to the machine may be able to setup tunnels circumventing this restriction.
