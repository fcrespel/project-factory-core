---
layout: page
title: Platform configuration
---

- Table of contents
{:toc}

## Prerequisites

Configuration of a new platform requires [Maven](http://maven.apache.org) to be correctly installed and configured, as mentioned in the [development environment](env.html) page.

A practical experience of Maven is recommended; the [Maven in 5 minutes](http://maven.apache.org/guides/getting-started/maven-in-five-minutes.html) guide is a good starting point for beginners.

## Product initialization

A new **Project Factory** platform configuration (also called “product”) can be easily created from a template, using a [Maven archetype](http://maven.apache.org/archetype/maven-archetype-plugin/generate-mojo.html).

To do so, execute one of the following commands in the directory under which the new product should be created:

    mvn archetype:generate -DarchetypeGroupId=fr.project-factory.core.archetypes -DarchetypeArtifactId=product -DarchetypeVersion=3.4.0-SNAPSHOT -DarchetypeRepository=https://forge.crespel.me/nexus/content/groups/project-factory/

The interactive mode of the archetype plugin will prompt you to enter the following details:

-   **groupId:** as you wish (e.g. `fr.project-factory.core.products` for official products).
-   **artifactId:** name of the product, in lowercase (e.g. `forge`).
-   **version:** version of the product (e.g. `1.0.0-SNAPSHOT`).
-   **package:** ignored, leave the suggested value.

After this intialization, a `pom.xml` will be generated as well as the base directory structure.

## Product configuration

Product configuration is defined in the `product.properties` file of the `src/main/resources` directory.

The main properties are the following:

    # Package properties
    package.prefix=projectfactory

    # Product properties
    product.release=0
    product.id=pf
    product.name=Project Factory
    product.root=/opt/projectfactory
    product.app=${product.root}/app
    product.backup=${product.root}/backup
    product.bin=${product.root}/bin
    product.data=${product.root}/data
    product.log=${product.root}/log
    product.tmp=${product.root}/tmp
    product.domain=project-factory.fr
    product.domain.alias=
    product.theme=basic
    product.scheme=https
    product.home=/portal
    product.locale=fr

    # Proxy properties
    proxy.host=
    proxy.port=0

    # LDAP properties
    ldap.host=127.0.0.1
    ldap.port=10389
    ldap.dn.attr=entryDn
    ldap.base.rdn.attr=dc
    ldap.base.rdn.value=project-factory
    ldap.base.dn=${ldap.base.rdn},dc=fr
    ldap.root.rdn.attr=cn
    ldap.root.rdn.value=root
    ldap.users.class=organizationalUnit
    ldap.users.rdn.attr=ou
    ldap.users.rdn.value=users
    ldap.user.class=inetOrgPerson
    ldap.user.rdn.attr=uid
    ldap.user.commonname.attr=cn
    ldap.user.displayname.attr=displayName
    ldap.user.firstname.attr=givenName
    ldap.user.lastname.attr=sn
    ldap.user.mail.attr=mail
    ldap.user.telephone.attr=telephoneNumber
    ldap.user.organization.attr=o
    ldap.user.password.attr=userPassword
    ldap.user.memberof.attr=memberOf
    ldap.groups.class=organizationalUnit
    ldap.groups.rdn.attr=ou
    ldap.groups.rdn.value=groups
    ldap.group.class=groupOfNames
    ldap.group.rdn.attr=cn
    ldap.group.member.attr=member
    ldap.group.displayname.attr=description

All available properties are stored in the `product-default.properties` file of the `products/default/src/main/resources` directory in `project-factory-core`.
