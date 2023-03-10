# ejbca-docker

[![version)](https://img.shields.io/docker/v/crashvb/ejbca/latest)](https://hub.docker.com/repository/docker/crashvb/ejbca)
[![image size](https://img.shields.io/docker/image-size/crashvb/ejbca/latest)](https://hub.docker.com/repository/docker/crashvb/ejbca)
[![linting](https://img.shields.io/badge/linting-hadolint-yellow)](https://github.com/hadolint/hadolint)
[![license](https://img.shields.io/github/license/crashvb/ejbca-docker.svg)](https://github.com/crashvb/ejbca-docker/blob/master/LICENSE.md)

## Overview

This docker image contains [EJBCA](https://ejbca.org/).

## Debugging jboss and ejbca

### Modify ejbca install to use jboss cli password

```bash
sed --in-place '/--command=/r /dev/stdin' $EJBCA_HOME/bin/jboss.xml <<- EOF
        <arg value="--user=admin" />
        <arg value="--password=\${env.JBOSS_PASSWORD}" />
EOF
```

### Expose ejbca cli arguments (including secrets!)

```bash
sed --in-place 's/ejbca:cli-hideargs/ejbca:cli/g' $EJBCA_HOME/bin/cli.xml
```

### Enable trace logging for ejbca cli

```bash
for i in ERROR WARN INFO DEBUG ; do
        sed --in-place "s/$i/TRACE/g" $EJBCA_HOME/dist/ejbca-ejb-cli/log4j.xml
done
sed --in-place 's/false/true/g' $EJBCA_HOME/dist/ejbca-ejb-cli/log4j.xml
```

### Enable trace logging for jboss remoting

_Reference: http://www.mastertheboss.com/jboss-server/jboss-log/5-loggers-in-jboss-you-should-know-about_

Add the following to `/usr/share/jboss/standalone/configuration/standalone.xml`
```xml
<logger category="org.jboss.remoting.remote">
        <level name="TRACE"/>
</logger>
```

## Entrypoint Scripts

### ejbca

The embedded entrypoint script is located at `/etc/entrypoint.d/20ejbca` and performs the following actions:

1. A new ejbca configuration is generated using the following environment variables:

 | Variable | Default Value | Description |
 | ---------| ------------- | ----------- |
 | EJBCA\_ADMIN\_PASSWORD | _random_ | The ejbca `admin` password. |
 | EJBCA\_CA\_NAME | ManagementCA | The name of the CA. |
 | EJBCA\_CA\_DN | CN=$EJBCA\_CA\_NAME,O=EJBCA Sample,C=SE | The distinguished name of the CA. |
 | EJBCA\_CA\_KEY\_SPEC | 4096 | The cryptographic key length. |
 | EJBCA\_CA\_KEY\_TYPE | RSA | The cryptography algorithm. |
 | EJBCA\_CA\_POLICY\_ID | null |  |
 | EJBCA\_CA\_SIGNATURE\_ALGORITHM | SHA256WithRSA | The signature algorithm. |
 | EJBCA\_CA\_TOKEN\_PASSWORD | null |  |
 | EJBCA\_CA\_VALIDITY\_DAYS | 30 | The time, in days, for which the CA is valid. |
 | EJBCA\_DATABASE\_HOST | ejbca-db | The ejbca database hostname. (mysql only) |
 | EJBCA\_DATABASE\_NAME | ejbca | The ejbca database name. (mysql only) |
 | EJBCA\_DATABASE\_PASSWORD | _random_ | The ejbca `database` password. |
 | EJBCA\_DATABASE\_PORT | 3306 | The ejbca database port. (mysql only) |
 | EJBCA\_DATABASE\_USERNAME | ejbca | The ejbca database username. (mysql only) |
 | EJBCA\_DATASOURCE | h2 | The datasource type (h2, postgres, mariadb, etc ...) |
 | EJBCA\_KEYSTORE\_PASSWORD | _random_ | The ejbca `keystore` password. |
 | EJBCA\_SERVER\_NAME | localhost | The name of the server. |
 | EJBCA\_SERVER\_DN | CN=$EJBCA\_SERVER\_NAME,O=EJBCA Sample,C=SE | The distinguished name of the server. |
 | EJBCA\_SUPERADMIN\_CN | SuperAdmin | The common name of the administrator. |
 | EJBCA\_SUPERADMIN\_DN | CN=$EJBCA\_SUPERADMIN\_CN | The distinguised name of the administrator.  |
 | EJBCA\_SUPERADMIN\_KEYSTORE\_BATCHED | true |  |
 | EJBCA\_TRUSTSTORE\_PASSWORD | _random_ | The ejbca `truststore` password. |

## Standard Configuration

### Container Layout

```
/
├─ etc/
│  └─ entrypoint.d/
│     └─ ejbca
├─ run/
│  └─ secrets/
│     ├─ ejbca_admin_password
│     ├─ ejbca_database_password
│     ├─ ejbca_keystore_password
│     └─ ejbca_truststore_password
├─ usr/
│  └─ share/
│     └─ ejbca/
└─ var/
   └─ lib/
      └─ ejbca/
         └─ p12/
            └─ superadmin.p12
```

### Exposed Ports

* `8080/tcp` - (_repurposed_) Public HTTP port of your application server, used for clients to access the public web for information. Not to be used for enrollment since it's not encrypted.
* `8442/tcp` - Public HTTPS port (server side only SSL) of your application server, used for clients to access the public web for enrollment.
* `8443/tcp` - SSL protected HTTPS port used to access the EJBCA Admin GUI. This port requires client certificate for access.

### Volumes

* `/var/lib/ejbca` - EJBCA data directory.

## See Also

* https://wiki.majic.rs/FreeSoftwareX509Cookbook/x509_infrastructure/certification_authority/setting-up_ejbca_as_certification_authority/#wiki-toc-preparing-ejbca-installation-files

## Development

[Source Control](https://github.com/crashvb/ejbca-docker)

