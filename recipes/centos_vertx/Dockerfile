# Copyright (c) 2012-2017 Red Hat, Inc
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html

FROM registry.centos.org/che-stacks/centos-jdk8

EXPOSE 8080 5005
LABEL che:server:8080:ref=vertx che:server:8080:protocol=http che:server:5005:ref=vertx-debug che:server:5005:protocol=http

MAINTAINER Clement Escoffier

ARG VERTX_VERSION=3.4.2

ENV VERTX_GROUPID=io.vertx 

COPY install-vertx-dependencies.sh /tmp/
RUN sudo chown user:user /tmp/install-vertx-dependencies.sh && \
    chmod +x /tmp/install-vertx-dependencies.sh && \
    scl enable rh-maven33 /tmp/install-vertx-dependencies.sh && \
    sudo rm -f /tmp/install-vertx-dependencies.sh && \
    sudo chgrp -R 0 /home/user && \
    sudo chmod -R g+rwX /home/user
