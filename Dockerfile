FROM crashvb/base:22.04-202303080156@sha256:7b0aea85d0f02978f4171e7dab3fe453e94918b138bea4966ebf241ce82fde23 AS parent

FROM keyfactor/ejbca-ce:7.11.0@sha256:0224d8ba2c5d99098ae311d397c28f0078d6853033d96297c75ca460d11e4f78
ARG org_opencontainers_image_created=undefined
ARG org_opencontainers_image_revision=undefined
LABEL \
	org.opencontainers.image.authors="Richard Davis <crashvb@gmail.com>" \
	org.opencontainers.image.base.digest="sha256:0224d8ba2c5d99098ae311d397c28f0078d6853033d96297c75ca460d11e4f78" \
	org.opencontainers.image.base.name="keyfactor/ejbca-ce:7.11.0" \
	org.opencontainers.image.created="${org_opencontainers_image_created}" \
	org.opencontainers.image.description="Image containing EJBCA." \
	org.opencontainers.image.licenses="Apache-2.0" \
	org.opencontainers.image.source="https://github.com/crashvb/ejbca-docker" \
	org.opencontainers.image.revision="${org_opencontainers_image_revision}" \
	org.opencontainers.image.title="crashvb/ejbca" \
	org.opencontainers.image.url="https://github.com/crashvb/ejbca-docker"

# hadolint ignore=DL3002
USER root

# Install packages, download files ...
COPY --from=parent /sbin/entrypoint /sbin/healthcheck /sbin/
COPY --from=parent /usr/local/lib/entrypoint.sh /usr/local/lib/
COPY docker-* ejbca-wrapper /sbin/
RUN docker-microdnf hostname shadow-utils unzip util-linux wget

# Configure: bash profile
RUN sed --in-place --expression="/^HISTSIZE/s/1000/9999/" --expression="/^HISTFILESIZE/s/2000/99999/" /root/.bashrc && \
	printf "set -o vi\n" >> /root/.bashrc && \
	printf "PS1='\${debian_chroot:+(\$debian_chroot)}\\\\t \[\\\\033[0;31m\]\u\[\\\\033[00m\]@\[\\\\033[7m\]\h\[\\\\033[00m\] [\w]\\\\n\$ '\n" >> /root/.bashrc && \
	touch ~/.hushlogin

# Configure: entrypoint
# hadolint ignore=SC2174
RUN mkdir --mode=0755 --parents /etc/entrypoint.d/ /etc/healthcheck.d/
COPY entrypoint.ejbca /etc/entrypoint.d/ejbca

ENV EJBCA_DATA=/mnt/external EJBCA_HOME=/opt/keyfactor/ejbca JBOSS_HOME=/opt/keyfactor/wildfly-26.1.2.Final
RUN mkdir --parents ${EJBCA_DATA} && \
	wget --quiet --output-document=/tmp/ZuluJCEPolicies.zip https://cdn.azul.com/zcek/bin/ZuluJCEPolicies.zip && \
	unzip -oj /tmp/ZuluJCEPolicies.zip ZuluJCEPolicies/local_policy.jar ZuluJCEPolicies/US_export_policy.jar -d /usr/lib/jvm/java-11-slim/lib/security/ && \
	rm --force /tmp/ZuluJCEPolicies.zip

# Configure: healthcheck
COPY healthcheck.java /etc/healthcheck.d/java

HEALTHCHECK CMD /sbin/healthcheck

# Configure: ejbca
RUN useradd --gid=0 --groups=tty --home=/opt --comment="ejbca user" --uid=10001 ejbca
COPY ejbca-renew-* /usr/local/bin/

ENTRYPOINT ["/sbin/entrypoint"]
CMD ["/sbin/ejbca-wrapper"]
