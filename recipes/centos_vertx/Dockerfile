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

EXPOSE 8080 5005
LABEL che:server:8080:ref=vertx che:server:8080:protocol=http che:server:5005:ref=vertx-debug che:server:5005:protocol=http

ARG JAVA_VERSION=1.8.0
ARG VERTX_VERSION=3.6.3

ENV VERTX_GROUPID=io.vertx 

COPY install-vertx-dependencies.sh /tmp/
RUN sudo chown user:user /tmp/install-vertx-dependencies.sh && \
    chmod +x /tmp/install-vertx-dependencies.sh && \
    scl enable rh-maven33 /tmp/install-vertx-dependencies.sh && \
    sudo rm -f /tmp/install-vertx-dependencies.sh && \
    sudo chgrp -R 0 /home/user && \
    sudo chmod -R g+rwX /home/user
