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
 | EJBCA\_DATABASE\_PASSWORD | _random_ | The ejbca `database` password. |
 | EJBCA\_KEYSTORE\_PASSWORD | _random_ | The ejbca `keystore` password. |
 | EJBCA\_TRUSTSTORE\_PASSWORD | _random_ | The ejbca `truststore` password. |

## Standard Configuration

### Container Layout

```
/
├─ etc/
│  └─ entrypoint.d/
│     └─ ejbca
├─ mnt/
│  ├─ external/
│  │  ├─ p12/
│  │  └─ secrets/
│  │     └─ tls/
│  │        ├─ ks/
│  │        │  ├─ server.jks
│  │        │  └─ server.storepasswd
│  │        └─ ts/
│  │           ├─ truststore.jks
│  │           └─ truststore.storepasswd
│  └─ persistent/
├─ opt/
│  └─ keyfactor/
│     ├─ ejbca/
│     └─ wildfly-x.y.z.Final/
│        └─ standalone/
│           └─ configuration/
└─ run/
   └─ secrets/
      ├─ ejbca_admin_password
      ├─ ejbca_database_password
      ├─ ejbca_keystore_password
      └─ ejbca_truststore_password
```

### Exposed Ports

* `8009/tcp` - Apache JServ Protocol. Used for HTTP clustering and load balancing.
* `8080/tcp` - Public HTTP port of your application server, used for clients to access the public web for information. Not to be used for enrollment since it's not encrypted.
* `8081/tcp` - HTTP back-end proxy port.
* `8082/tcp` - HTTP back-end proxy port with client certificate headers.
* `8442/tcp` - Public HTTPS port (server side only SSL) of your application server, used for clients to access the public web for enrollment.
* `8443/tcp` - SSL protected HTTPS port used to access the EJBCA Admin GUI. This port requires client certificate for access.

### Volumes

* `/mnt/external` - EJBCA data directory (static).
* `/mnt/persistent` - EJBCA data directory (dynamic).

## Development

[Source Control](https://github.com/crashvb/ejbca-docker)

