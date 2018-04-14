---
layout: page
title: Integration standards
---

The following items must be observed when integrating a new service/tool in **Project Factory**:

-   Completely **automated installation** (no manual step to begin using the service).
-   **System services** complying with [LSB standards](http://refspecs.linuxbase.org/LSB_3.1.1/LSB-Core-generic/LSB-Core-generic/tocsysinit.html) and running as a dedicated system user.
-   Configurable **listening ports**, specific to each product (to allow multiple instances on the same machine).
-   CAS and LDAP **authentication**, with LDAP account synchronization if applicable.
-   Global **theme** as configured by the portal.
-   Global **toolbar** integration at the top of each page.
-   **Integration** with other platform services if applicable.
-   Automated **backups**.
-   Nagios **monitoring**.

You may refer to existing packages for sample implementations.
