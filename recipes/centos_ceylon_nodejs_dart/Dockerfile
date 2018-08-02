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

# Install nodejs for ls agents
RUN sudo yum update -y && \
    curl -sL https://rpm.nodesource.com/setup_6.x | sudo -E bash - && \
    sudo yum install -y bzip2 tar nodejs && \
    sudo yum clean all && \
    sudo rm -rf /tmp/* /var/cache/yum && \
    sudo ln -s /usr/bin/node /usr/bin/nodejs


ENV HOME /home/user

ENV CEYLON_ROOT $HOME/ceylon
ENV DART_ROOT $HOME/dart
ENV DART_HOME $DART_ROOT/dart-sdk
ENV CEYLON_VERSION 1.3.2
ENV CEYLON_HOME ${CEYLON_ROOT}/ceylon-${CEYLON_VERSION}
ENV CEYLON_BIN ${CEYLON_HOME}/bin/ceylon
 
RUN mkdir -p ${CEYLON_ROOT} \
    && mkdir -p ${DART_ROOT}
 
#######################
### Install Ceylon  ###
#######################
 
RUN echo "downloading Ceylon distribution ..." \
  && curl -s https://downloads.ceylon-lang.org/cli/ceylon-${CEYLON_VERSION}.zip > ${CEYLON_ROOT}/ceylon-${CEYLON_VERSION}.zip \
  && echo "unzipping Ceylon distribution ..." \
  && unzip -d ${CEYLON_ROOT} ${CEYLON_ROOT}/ceylon-${CEYLON_VERSION}.zip \
  && rm -f ${CEYLON_ROOT}/ceylon-${CEYLON_VERSION}.zip

RUN echo "downloading Dart distribution ..." \
  && curl -s https://storage.googleapis.com/dart-archive/channels/stable/release/1.24.2/sdk/dartsdk-linux-x64-release.zip > ${DART_ROOT}/dartsdk-linux-x64-release.zip \
  && echo "unzipping Dart distribution ..." \
  && unzip -d ${DART_ROOT} ${DART_ROOT}/dartsdk-linux-x64-release.zip \
  && rm -f ${DART_ROOT}/dartsdk-linux-x64-release.zip

ENV PATH $PATH:$CEYLON_HOME/bin:$DART_HOME/bin

RUN ceylon plugin install --force com.vasileff.ceylon.dart.cli/1.3.2-DP4 \
    && ceylon install-dart --out +USER && \
    sudo chgrp -R 0 ${HOME}/dart && \
    sudo chmod -R g+rwX ${HOME}/dart
