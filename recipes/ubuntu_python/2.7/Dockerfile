# Copyright (c) 2012-2018 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#
# Contributors:
#   Red Hat, Inc. - initial API and implementation

FROM eclipse/stack-base:ubuntu

RUN sudo apt-get update && \
    sudo apt-get install -y gcc make zlibc zlib1g zlib1g-dev libssl-dev && \
    sudo apt-get install -y python python-pip
RUN sudo pip install --no-cache-dir virtualenv
EXPOSE 8080
