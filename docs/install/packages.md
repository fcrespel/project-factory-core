---
layout: page
title: Packages installation
---

**IMPORTANT:** [pre-requisites](prereqs.html) must have been completed before any installation of **Project Factory** packages.

In the instructions below:

-   Commands must be executed as **root** (add `sudo` before the command if necessary).
-   Replace the `projectfactory` prefix with the value of the `package.prefix` property for the target product (e.g. `ittoolbox`).
-   Replace the `pf` prefix by the value of the `product.id` property for the target product (e.g. `ittb`).

## Core package

The first package to install or update, independently of any other, is the “core” of **Project Factory**.

To do so, use the system package manager:

-   For **RPM**-based distributions (RedHat/CentOS):

        yum install projectfactory-core

-   For **DEB**-based distributions (Debian/Ubuntu):

        apt-get install projectfactory-core


## System packages

Use the **Project Factory** administration tool to install a system package:

    pf-admin package install system activemq
    pf-admin package install system ant
    pf-admin package install system elasticsearch
    pf-admin package install system httpd
    pf-admin package install system ldap
    pf-admin package install system maven2
    pf-admin package install system maven3
    pf-admin package install system mysql
    pf-admin package install system php
    pf-admin package install system python
    pf-admin package install system redis
    pf-admin package install system ruby
    pf-admin package install system tomcat

## Administration packages

Use the **Project Factory** administration tool to install an admin package:

    pf-admin package install admin cas-management
    pf-admin package install admin kibana
    pf-admin package install admin nagios
    pf-admin package install admin phpldapadmin
    pf-admin package install admin phpmyadmin
    pf-admin package install admin piwik

## Service packages

Use the **Project Factory** administration tool to install a service package:

    pf-admin package install service alfresco-explorer
    pf-admin package install service alfresco-share
    pf-admin package install service alfresco-solr
    pf-admin package install service api
    pf-admin package install service cas
    pf-admin package install service drupal
    pf-admin package install service gitlab
    pf-admin package install service jenkins
    pf-admin package install service jenkins-slave
    pf-admin package install service manager
    pf-admin package install service nexus
    pf-admin package install service osqa
    pf-admin package install service portal
    pf-admin package install service redmine
    pf-admin package install service rundeck
    pf-admin package install service sonarqube
    pf-admin package install service sonarqube-runner
    pf-admin package install service svn
    pf-admin package install service testlink
