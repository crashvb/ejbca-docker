# ejbca-docker

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
 | EJBCA_ADMIN_PASSWORD | _random_ | The ejbca `admin` password. |
 | EJBCA_CA_NAME | ManagementCA | The name of the CA. |
 | EJBCA_CA_DN | CN=$EJBCA_CA_NAME,O=EJBCA Sample,C=SE | The distinguished name of the CA. |
 | EJBCA_CA_KEY_SPEC | 4096 | The cryptographic key length. |
 | EJBCA_CA_KEY_TYPE | RSA | The cryptography algorithm. |
 | EJBCA_CA_POLICY_ID | null |  |
 | EJBCA_CA_SIGNATURE_ALGORITHM | SHA256WithRSA | The signature algorithm. |
 | EJBCA_CA_TOKEN_PASSWORD | null |  |
 | EJBCA_CA_VALIDITY_DAYS | 30 | The time, in days, for which the CA is valid. |
 | EJBCA_DATABASE_HOST | ejbca-db | The ejbca database hostname. (mysql only) |
 | EJBCA_DATABASE_NAME | ejbca | The ejbca database name. (mysql only) |
 | EJBCA_DATABASE_PASSWORD | _random_ | The ejbca `database` password. |
 | EJBCA_DATABASE_PORT | 3306 | The ejbca database port. (mysql only) |
 | EJBCA_DATABASE_USERNAME | ejbca | The ejbca database username. (mysql only) |
 | EJBCA_DATASOURCE | h2 | The datasource type (h2, postgres, mariadb, etc ...) |
 | EJBCA_KEYSTORE_PASSWORD | _random_ | The ejbca `keystore` password. |
 | EJBCA_SERVER_NAME | localhost | The name of the server. |
 | EJBCA_SERVER_DN | CN=$EJBCA_SERVER_NAME,O=EJBCA Sample,C=SE | The distinguished name of the server. |
 | EJBCA_SUPERADMIN_CN | SuperAdmin | The common name of the administrator. |
 | EJBCA_SUPERADMIN_DN | CN=$EJBCA_SUPERADMIN_CN | The distinguised name of the administrator.  |
 | EJBCA_SUPERADMIN_KEYSTORE_BATCHED | true |  |
 | EJBCA_TRUSTSTORE_PASSWORD | _random_ | The ejbca `truststore` password. |

## Standard Configuration

### Container Layout

```
/
├─ etc/
│  └─ entrypoint.d/
│     └─ 20ejbca
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

* `8442/tcp` - SSL-encrypted connection between deployed web applications and clients.
* `8443/tcp` - (_repurposed_) SSL-encrypted port used to access the EJBCA admin GUI.

### Volumes

* `/var/lib/ejbca` - EJBCA data directory.

## See Also

* https://wiki.majic.rs/FreeSoftwareX509Cookbook/x509_infrastructure/certification_authority/setting-up_ejbca_as_certification_authority/#wiki-toc-preparing-ejbca-installation-files

## Development

[Source Control](https://github.com/crashvb/ejbca-docker)

