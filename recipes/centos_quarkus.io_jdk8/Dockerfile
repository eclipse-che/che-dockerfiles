# Copyright (c) 2019-2019 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#
# Contributors:
#   Red Hat, Inc. - initial API and implementation
FROM registry.centos.org/che-stacks/centos-jdk8

MAINTAINER Michael Vorburger <mike@vorburger.ch>

EXPOSE 8080
LABEL che:server:8080:ref=quarkus che:server:8080:protocol=http

COPY install_quarkus_dependencies.sh /tmp/
RUN sudo chown user:user /tmp/install_quarkus_dependencies.sh && \
    sudo chmod a+x /tmp/install_quarkus_dependencies.sh && \
    scl enable rh-maven33 /tmp/install_quarkus_dependencies.sh && \
    sudo rm -f /tmp/install_quarkus_dependencies.sh && \
    sudo chgrp -R 0 /home/user && \
    sudo chmod -R g+rwX /home/user
