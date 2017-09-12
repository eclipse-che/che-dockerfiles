# Copyright (c) 2012-2017 Red Hat, Inc
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html

FROM registry.centos.org/che-stacks/centos-stack-base
EXPOSE 8080

MAINTAINER Dharmit Shah <dshah@redhat.com>

RUN sudo yum -y update && \
    sudo yum -y install epel-release \ 
                        python-pip && \
    sudo pip install --upgrade pip && \
    sudo pip install --no-cache-dir virtualenv && \
    sudo yum clean all
