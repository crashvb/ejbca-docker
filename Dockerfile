FROM crashvb/jboss:ubuntu
LABEL maintainer "Richard Davis <crashvb@gmail.com>"

# Install packages, download files ...
ENV EJBCA_DATA=/var/lib/ejbca EJBCA_HOME=/usr/share/ejbca EJBCA_VERSION=6_10_1_2
RUN mkdir --parents ${EJBCA_DATA} && \
	docker-apt ant ant-optional libmysql-java unzip && \
	wget --quiet --output-document=/tmp/ejbca.zip https://sourceforge.net/projects/ejbca/files/ejbca6/ejbca_${EJBCA_VERSION%_*_*}_0/ejbca_ce_${EJBCA_VERSION}.zip && \
	unzip -q /tmp/ejbca.zip -d /usr/share && \
	rm --force /tmp/ejbca.zip && \
	mv /usr/share/ejbca_ce_${EJBCA_VERSION} ${EJBCA_HOME} && \
	echo "appserver.home=${JBOSS_HOME}" >> ${EJBCA_HOME}/conf/ejbca.properties && \
	chown --recursive jboss:jboss ${EJBCA_DATA} ${EJBCA_HOME} && \
	ln --symbolic ${EJBCA_HOME}/bin/ejbca.sh /usr/local/bin/ejbca && \
	wget --quiet --output-document=/tmp/ZuluJCEPolicies.zip https://cdn.azul.com/zcek/bin/ZuluJCEPolicies.zip && \
	unzip -oj /tmp/ZuluJCEPolicies.zip ZuluJCEPolicies/local_policy.jar -d /usr/lib/jvm/java-7-openjdk-amd64/jre/lib/security/ && \
	unzip -oj /tmp/ZuluJCEPolicies.zip ZuluJCEPolicies/US_export_policy.jar -d /usr/lib/jvm/java-7-openjdk-amd64/jre/lib/security/ && \
	rm --force /tmp/ZuluJCEPolicies.zip

# Configure: ejbca
ADD *.properties.* /usr/local/share/ejbca/

# Configure: jboss
ADD jboss.index.html ${JBOSS_HOME}/welcome-content/index.html

# Configure: jboss: mysql

ADD jboss.driver.*.xml /usr/local/share/jboss/
ADD jboss.module.mysql.xml ${JBOSS_HOME}/modules/com/mysql/main/module.xml
RUN cp --preserve /usr/share/java/mysql-connector-java-*.jar ${JBOSS_HOME}/modules/com/mysql/main/mysql-connector-java.jar && \
	sed --in-place '/<drivers>/r/usr/local/share/jboss/jboss.driver.mysql.xml' ${JBOSS_HOME}/standalone/configuration/standalone.xml

# Configure: entrypoint
ADD entrypoint.ejbca /etc/entrypoint.d/20ejbca

EXPOSE 8442/tcp 8443/tcp

VOLUME ${EJBCA_DATA}
