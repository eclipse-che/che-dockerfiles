# Copyright (c) 2012-2017 Red Hat, Inc
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html

FROM registry.centos.org/che-stacks/centos-jdk8

MAINTAINER Dharmit Shah

EXPOSE 8080
LABEL che:server:8080:ref=wildfly che:server:8080:protocol=http

ARG SWARM_VERSION=2018.4.1

COPY install-swarm-dependencies.sh /tmp/
RUN sudo chown user:user /tmp/install-swarm-dependencies.sh && \
    chmod a+x /tmp/install-swarm-dependencies.sh && \
    scl enable rh-maven33 /tmp/install-swarm-dependencies.sh && \
    sudo rm -f /tmp/install-swarm-dependencies.sh && \
    sudo chgrp -R 0 /home/user && \
    sudo chmod -R g+rwX /home/user
