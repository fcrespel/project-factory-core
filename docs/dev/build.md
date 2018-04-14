---
layout: page
title: Building
---

- Table of contents
{:toc}

## Prerequisites

Building platform packages requires [Maven](http://maven.apache.org) to be correctly installed and configured, as mentioned in the [development environment](env.html) page.

A practical experience of Maven is recommended; the [Maven in 5 minutes](http://maven.apache.org/guides/getting-started/maven-in-five-minutes.html) guide is a good starting point for beginners.

## Build environment

The build environment of a platform must be based on the **target operating system** (e.g. CentOS 7).

To ease the installation of required build dependencies, the `${PACKAGE_PREFIX}-devel` package may be installed using the [administration tool](../admin/tool.html) (this is already done in the development/test [Vagrant VM](vm.html)).

**IMPORTANT:** the system user of the platform (`pf` by default) must be used to build packages. You may switch to it using the `sudo su - pf` command.

## Product build

The **Project Factory** “product” (see [Platform configuration](product.html)) must be installed in the local Maven repository before building packages.

To do so, change to the Maven project directory of the product and execute this command:

    mvn clean install

## Packages build

**Project Factory** packages may be built locally, installed to a local Maven repository (as shown below), or deployed to an artifact repository such as Nexus.

The following command must be executed from the  `project-factory-core/packages` directory first, then from the `project-factory-packages` directory or any subdirectory as necessary:

    mvn --fail-at-end clean install

To avoid building DEB packages, add `-P !deb` to the command line.  
To avoid building RPM packages, add `-P !rpm` to the command line.

When the `${PACKAGE_PREFIX}-devel` package is installed, its associated product and system profile are automatically used to build packages. In its absence, by default the `default` product and `system-el7-x86_64.properties` system profile will be used.

To define the product to build for manually, add the following arguments to the command line:

    -Dproperties.product.groupId=... -Dproperties.product.artifactId=... -Dproperties.product.version=...

To define the system profile to build for manually, add the following argument to the command line:

    -Dproperties.system.file=...

Possible values are:

-   `system-debian9-amd64.properties`
-   `system-el7-x86_64.properties`
-   `system-opensuse423-x86_64.properties`
-   `system-ubuntu1604-amd64.properties`

## Creating a package repository

The local Maven repository (referred as `$REPO_DIR` below) may serve as a package repository for `yum` or `apt-get`.

-   To create a **Yum** repository, execute this command:

        createrepo --update "$REPO_DIR"

-   To create a **Debian** repository, execute this command:

        cd $REPO_DIR && dpkg-scanpackages . | gzip -9c > "$REPO_DIR/Packages.gz"

For **production** use, it is recommended to collect RPM/DEB packages in a dedicated directory instead of using the Maven repository. It may then be exposed over HTTP/HTTPS for easy access by target machines.
