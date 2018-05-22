---
layout: page
title: Directory structure
---

The standard directory structure of a **Project Factory** platform is described below.
The main directories can be modified with **product properties** (mentioned between parentheses).
In **production**, it is recommended to have separate partitions (or logical volumes) for each of these directories.

    +---opt
        \---projectfactory             Platform root (product.root)
            +---app                    Application binaries, static configuration (product.app)
            |   \---admin
            |   \---services
            |   \---system
            +---backup                 Data backups (product.backup)
            |   \---admin
            |   \---services
            |   \---system
            +---bin                    Platform binaries (product.bin)
            |   \---backup.d           Backup/restore scripts
            |   \---cron.5mins         Scripts executed every 5 minutes
            |   \---cron.hourly        Scripts executed every hour
            |   \---cron.daily         Scripts executed every day
            |   \---init.d             System service scripts
            |   \---profile.d          System user profile scripts
            |   \---tools.d            Administration scripts
            +---data                   Application data (product.data)
            |   \---admin
            |   \---services
            |   \---system
            +---log                    Application logs (product.log)
            |   \---admin
            |   \---services
            |   \---system
            \---tmp                    Temporary storage (product.tmp)
