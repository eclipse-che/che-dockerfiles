# Copyright (c) 2012-2017 Red Hat, Inc
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html

FROM registry.centos.org/centos/centos

ARG JAVA_VERSION=1.8.0

ENV GOPATH=/go \
    PATH=$GOPATH/bin:/usr/local/go/bin:$PATH \
    JAVA_HOME=/usr/lib/jvm/java-${JAVA_VERSION}

RUN yum -y update && \
    yum -y install sudo openssh-server g++ gcc glibc-devel make golang java-${JAVA_VERSION}-openjdk-devel && \
    yum clean all && \
    sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config && \
    sed -ri 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config && \
    echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    useradd -u 1000 -G users,wheel -d /home/user --shell /bin/bash -m user && \
    usermod -p "*" user && \
    sed -i 's/requiretty/!requiretty/g' /etc/sudoers && \
    mkdir -p "$GOPATH/src" "$GOPATH/bin" && sudo chmod -R 777 "$GOPATH"

USER user

EXPOSE 8080
