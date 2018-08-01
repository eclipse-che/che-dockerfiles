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

MAINTAINER Dharmit Shah

EXPOSE 8080
LABEL che:server:8080:ref=wildfly che:server:8080:protocol=http

ARG SWARM_VERSION=2018.5.0

COPY install-swarm-dependencies.sh /tmp/
RUN sudo chown user:user /tmp/install-swarm-dependencies.sh && \
    chmod a+x /tmp/install-swarm-dependencies.sh && \
    scl enable rh-maven33 /tmp/install-swarm-dependencies.sh && \
    sudo rm -f /tmp/install-swarm-dependencies.sh && \
    sudo chgrp -R 0 /home/user && \
    sudo chmod -R g+rwX /home/user
