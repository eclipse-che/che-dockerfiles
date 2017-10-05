# Copyright (c) 2012-2017 Red Hat, Inc
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html

FROM registry.centos.org/che-stacks/centos-stack-base:latest

RUN sudo yum -y update && \
    sudo yum -y install centos-release-dotnet && \
    sudo yum -y install rh-dotnet20 && \
    sudo yum clean all && \
    cat /opt/rh/rh-dotnet20/enable >> /home/user/.bashrc

ENV PATH /opt/rh/rh-dotnet20/root/usr/bin:/opt/rh/rh-dotnet20/root/usr/sbin${PATH:+:${PATH}}

EXPOSE 5000
