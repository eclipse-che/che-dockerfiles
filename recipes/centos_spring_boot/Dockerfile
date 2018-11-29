# Copyright (c) 2012-2018 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#
# Contributors:
#   Red Hat, Inc. - initial API and implementation
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
    sudo rm -f /tmp/install_spring_boot_dependencies.sh && \
    sudo chgrp -R 0 /home/user && \
    sudo chmod -R g+rwX /home/user
