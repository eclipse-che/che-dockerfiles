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
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd && \
    echo "user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    sed -i 's/Defaults    requiretty/#Defaults    requiretty/g' /etc/sudoers && \
    useradd -u 1000 -G users,wheel -d /home/user --shell /bin/bash -m user && \
    usermod -p "*" user

RUN yum -y install rh-nodejs4 && \
    yum -y clean all && \
    scl enable rh-nodejs4 'npm install -g npm@latest' && \
    scl enable rh-nodejs4 'npm install --unsafe-perm -g gulp bower grunt grunt-cli yeoman-generator yo generator-angular generator-karma generator-webapp'

EXPOSE 3000 5000 9000 8080

WORKDIR /projects

USER user

CMD tail -f /dev/null
