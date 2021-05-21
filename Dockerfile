# primekey/ejbca-ce:7.4.3.2
FROM primekey/ejbca-ce@sha256:a8046dd8d6ebb7602bf3b0a564c0d5dded303d84268f1400354a44f1d0669faa
LABEL maintainer "Richard Davis <crashvb@gmail.com>"

USER root

# Install packages, download files ...
ADD docker-* entrypoint healthcheck /sbin/
ADD entrypoint.sh /usr/local/lib/
RUN docker-microdnf shadow-utils unzip util-linux wget

# Configure: bash profile
RUN sed --in-place --expression="/^HISTSIZE/s/1000/9999/" --expression="/^HISTFILESIZE/s/2000/99999/" /root/.bashrc && \
	echo "set -o vi" >> /root/.bashrc && \
	echo "PS1='\\t \[\\033[0;31m\]\u\[\\033[00m\]@\[\\033[7m\]\h\[\\033[00m\] [\w]\\n\$ '" >> /root/.bashrc && \
	touch ~/.hushlogin

# Configure: entrypoint
RUN mkdir --mode=0755 --parents /etc/entrypoint.d/ /etc/healthcheck.d/
ADD entrypoint.ejbca /etc/entrypoint.d/20ejbca

ENV EJBCA_DATA=/mnt/persistent EJBCA_HOME=/opt/primekey/ejbca JBOSS_HOME=/opt/primekey/wildfly-22.0.1.Final
RUN mkdir --parents ${EJBCA_DATA} && \
	wget --quiet --output-document=/tmp/ZuluJCEPolicies.zip https://cdn.azul.com/zcek/bin/ZuluJCEPolicies.zip && \
	unzip -oj /tmp/ZuluJCEPolicies.zip ZuluJCEPolicies/local_policy.jar ZuluJCEPolicies/US_export_policy.jar -d /usr/lib/jvm/java-11-slim/lib/security/ && \
	rm --force /tmp/ZuluJCEPolicies.zip

# Configure: ejbca
ENV EP_USER=ejbca
RUN useradd --gid=0 --groups=tty --home=/opt --comment="ejbca user" --uid=1001 ejbca
ADD ejbca-renew-* /usr/local/bin/

ENTRYPOINT ["/sbin/entrypoint"]
CMD ["/opt/primekey/bin/start.sh"]
