# Copyright (c) 2012-2017 Red Hat, Inc
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html

FROM registry.centos.org/che-stacks/centos-stack-base

MAINTAINER Dharmit Shah <dshah@redhat.com>

EXPOSE 3000 5000 9000 8080
LABEL che:server:3000:ref=nodejs-3000 che:server:3000:protocol=http che:server:5000:ref=nodejs-5000 che:server:5000:protocol=http che:server:9000:ref=nodejs-9000 che:server:9000:protocol=http che:server:8080:ref=nodejs-8080 che:server:8080:protocol=http

RUN sudo yum update && \
    sudo yum -y install rh-nodejs4 && \
    sudo yum -y clean all && \
    scl enable rh-nodejs4 'npm install -g npm@latest' && \
    scl enable rh-nodejs4 'npm install --unsafe-perm -g gulp bower grunt grunt-cli yeoman-generator yo generator-angular generator-karma generator-webapp' && \
    cat /opt/rh/rh-nodejs4/enable >> /home/user/.bashrc
