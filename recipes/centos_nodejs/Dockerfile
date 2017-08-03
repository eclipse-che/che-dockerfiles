# Copyright (c) 2012-2017 Red Hat, Inc
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html

FROM registry.centos.org/centos/centos

MAINTAINER Dharmit Shah <dshah@redhat.com>

RUN yum -y update && \
    yum -y install git sudo openssh-server centos-release-scl && \
    yum clean all && \
    sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config && \
    sed -ri 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config && \
    echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    useradd -u 1000 -G users,wheel -d /home/user --shell /bin/bash -m user && \
    usermod -p "*" user && \
    sed -i 's/requiretty/!requiretty/g' /etc/sudoers

RUN yum -y install rh-nodejs4 && \
    yum -y clean all && \
    scl enable rh-nodejs4 'npm install -g npm@latest' && \
    scl enable rh-nodejs4 'npm install --unsafe-perm -g gulp bower grunt grunt-cli yeoman-generator yo generator-angular generator-karma generator-webapp' && \
    cat /opt/rh/rh-nodejs4/enable >> /home/user/.bashrc

LABEL che:server:3000:ref=nodejs-3000 che:server:3000:protocol=http che:server:5000:ref=nodejs-5000 che:server:5000:protocol=http che:server:9000:ref=nodejs-9000 che:server:9000:protocol=http che:server:8080:ref=nodejs-8080 che:server:8080:protocol=http

EXPOSE 3000 5000 9000 8080

WORKDIR /projects

USER user

CMD tail -f /dev/null
