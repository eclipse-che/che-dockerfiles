# Copyright (c) 2012-2017 Red Hat, Inc
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html

FROM registry.centos.org/centos/centos

MAINTAINER Clement Escoffier

ARG JAVA_VERSION=1.8.0
ARG VERTX_VERSION=3.4.0

ENV VERTX_GROUPID=io.vertx \
    JAVA_HOME=/usr/lib/jvm/java-${JAVA_VERSION} \
    M2_HOME=/opt/rh/rh-maven33/root/usr/share/maven

RUN yum -y update && \
    yum -y install sudo openssh-server centos-release-scl tar curl && \
    yum -y install rh-maven33 java-${JAVA_VERSION}-openjdk-devel && \
    yum clean all && \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd && \
    echo "user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    sed -i 's/Defaults    requiretty/#Defaults    requiretty/g' /etc/sudoers && \
    useradd -u 1000 -G users,wheel -d /home/user --shell /bin/bash -m user && \
    usermod -p "*" user

RUN mkdir -p /projects && \
    chgrp -R 0 /projects && \
    chmod -R g+rwX /projects

COPY install-vertx-dependencies.sh /tmp/
RUN chown user:user /tmp/install-vertx-dependencies.sh && \
chmod a+x /tmp/install-vertx-dependencies.sh
USER user

RUN scl enable rh-maven33 /tmp/install-vertx-dependencies.sh && \
    sudo rm -f /tmp/install-vertx-dependencies.sh

EXPOSE 8080

CMD tail -f /dev/null
