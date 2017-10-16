# Copyright (c) 2012-2017 Red Hat, Inc
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
FROM registry.centos.org/che-stacks/centos-jdk8

MAINTAINER Gytis Trikleris

EXPOSE 8080
LABEL che:server:8080:ref=springboot che:server:8080:protocol=http 

ARG SPRING_BOOT_VERSION=1.4.1.RELEASE
ARG JUNIT_VERSION=4.12

ENV SPRING_BOOT_GROUP=org.springframework.boot

COPY install_spring_boot_dependencies.sh /tmp/
RUN sudo chown user:user /tmp/install_spring_boot_dependencies.sh && \
    sudo chmod a+x /tmp/install_spring_boot_dependencies.sh && \
    scl enable rh-maven33 /tmp/install_spring_boot_dependencies.sh && \
    sudo rm -f /tmp/install_spring_boot_dependencies.sh
