# Copyright (c) 2012-2017 Red Hat, Inc
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html

FROM registry.centos.org/centos/centos

MAINTAINER Dharmit Shah

ARG JAVA_VERSION=1.8.0
ARG SWARM_VERSION=2017.7.0

ENV JAVA_HOME=/usr/lib/jvm/java-${JAVA_VERSION} \
    M2_HOME=/opt/rh/rh-maven33/root/usr/share/maven

RUN yum -y update && \
    yum -y install wget sudo openssh-server centos-release-scl && \
    yum -y install rh-maven33 java-${JAVA_VERSION}-openjdk-devel && \
    yum clean all && \
    sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config && \
    sed -ri 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config && \
    echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    useradd -u 1000 -G users,wheel -d /home/user --shell /bin/bash -m user && \
    usermod -p "*" user && \
    sed -i 's/requiretty/!requiretty/g' /etc/sudoers && \
    cat /opt/rh/rh-maven33/enable >> /home/user/.bashrc

COPY install-swarm-dependencies.sh /tmp/
RUN chown user:user /tmp/install-swarm-dependencies.sh && \
    chmod a+x /tmp/install-swarm-dependencies.sh
USER user

LABEL che:server:8080:ref=tomcat che:server:8080:protocol=http che:server:8000:ref=tomcat-jpda che:server:8000:protocol=http

RUN scl enable rh-maven33 /tmp/install-swarm-dependencies.sh && \
    sudo rm -f /tmp/install-swarm-dependencies.sh

EXPOSE 8080

WORKDIR /projects

CMD tail -f /dev/null
