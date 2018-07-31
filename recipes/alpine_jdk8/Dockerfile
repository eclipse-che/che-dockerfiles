# Copyright (c) 2012-2018 Red Hat, Inc.
# This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v2.0
# which is available at http://www.eclipse.org/legal/epl-2.0.html
#
# SPDX-License-Identifier: EPL-2.0
#
# Contributors:
#   Red Hat, Inc. - initial API and implementation

FROM openjdk:8u111-jre-alpine

ENV LANG=C.UTF-8 \
    DOCKER_VERSION=1.6.0 \
    DOCKER_BUCKET=get.docker.com \
    CHE_IN_CONTAINER=true \
    MAVEN_VERSION=3.3.9
ENV M2_HOME=/usr/lib/apache-maven-$MAVEN_VERSION
ENV PATH=${PATH}:${M2_HOME}/bin

RUN echo "http://dl-4.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    apk add --update sudo curl ca-certificates bash openssh unzip openssl shadow && \
    curl -sSL "https://${DOCKER_BUCKET}/builds/Linux/x86_64/docker-${DOCKER_VERSION}" -o /usr/bin/docker && \
    chmod +x /usr/bin/docker && \
    cd /tmp && \
    wget -q "http://apache.ip-connect.vn.ua/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz" && \
    tar -xzf "apache-maven-$MAVEN_VERSION-bin.tar.gz" && \
    mv "/tmp/apache-maven-$MAVEN_VERSION" "/usr/lib" && \
    echo "%root ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    rm -rf /tmp/* /var/cache/apk/* && \
    adduser -S user -h /home/user -s /bin/bash -G root -u 1000 && \
    echo "%root ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    usermod -p "*" user && \
    sudo chown -R user /home/user/ && \
    sudo mkdir -p /home/user/.m2 && \
    sudo mkdir -p /home/user/jdtls/data && \
    sudo chgrp -R 0 ${HOME} && \
    sudo chmod -R g+rwX ${HOME}

EXPOSE 22 8000 8080

USER user

WORKDIR /projects

COPY open-jdk-source-file-location /open-jdk-source-file-location

CMD sudo /usr/bin/ssh-keygen -A && \
    sudo /usr/sbin/sshd -D && \
    sudo su - && \
    tail -f /dev/null
