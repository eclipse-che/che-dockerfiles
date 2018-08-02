# Copyright (c) 2012-2018 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#
# Contributors:
#   Red Hat, Inc. - initial API and implementation

FROM eclipse/debian_jdk8
RUN sudo apt-get update && \
    sudo apt-get -y install build-essential libkrb5-dev gcc make ruby-full rubygems debian-keyring python2.7 && \
    sudo gem install --no-rdoc --no-ri sass -v 3.4.22 && \
    sudo gem install --no-rdoc --no-ri compass && \
    sudo apt-get clean && \
    sudo apt-get -y autoremove && \
    sudo apt-get -y clean && \
    sudo rm -rf /var/lib/apt/lists/*

RUN wget -qO- https://deb.nodesource.com/setup_7.x | sudo -E bash -
RUN sudo apt update && sudo apt -y install nodejs

EXPOSE 1337 3000 4200 5000 9000 8003
RUN sudo npm install --unsafe-perm -g gulp bower grunt grunt-cli yeoman-generator yo generator-angular generator-karma generator-webapp
LABEL che:server:8003:ref=angular che:server:8003:protocol=http che:server:3000:ref=node-3000 che:server:3000:protocol=http che:server:9000:ref=node-9000 che:server:9000:protocol=http
