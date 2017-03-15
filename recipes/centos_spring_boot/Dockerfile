# Copyright (c) 2012-2017 Red Hat, Inc
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
FROM registry.centos.org/centos/centos

MAINTAINER Gytis Trikleris

ARG JAVA_VERSION=1.8.0
ARG SPRING_BOOT_VERSION=1.4.1.RELEASE
ARG JUNIT_VERSION=4.12

ENV SPRING_BOOT_GROUP=org.springframework.boot

RUN yum -y update && \
    yum -y install sudo openssh-server centos-release-scl && \
    yum -y install rh-maven33 java-${JAVA_VERSION}-openjdk-devel && \
    yum clean all && \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd && \
    echo "user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    sed -i 's/Defaults    requiretty/#Defaults    requiretty/g' /etc/sudoers && \
    useradd -u 1000 -G users,wheel -d /home/user --shell /bin/bash -m user && \
    usermod -p "*" user

COPY install_spring_boot_dependencies.sh /tmp/

RUN chown user:user /tmp/install_spring_boot_dependencies.sh && \
    chmod a+x /tmp/install_spring_boot_dependencies.sh

USER user

RUN scl enable rh-maven33 /tmp/install_spring_boot_dependencies.sh && \
    sudo rm -f /tmp/install_spring_boot_dependencies.sh

EXPOSE 8080

CMD tail -f /dev/null
