# Copyright (c) 2012-2017 Red Hat, Inc
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html

FROM registry.centos.org/centos/centos

MAINTAINER Dharmit Shah <dshah@redhat.com>

RUN yum -y update && \
    yum -y install sudo openssh-server git && \
    yum clean all && \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd && \
    echo "user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    sed -i 's/Defaults    requiretty/#Defaults    requiretty/g' /etc/sudoers && \
    useradd -u 1000 -G users,wheel -d /home/user --shell /bin/bash -m user && \
    usermod -p "*" user

USER user

CMD tail -f /dev/null
