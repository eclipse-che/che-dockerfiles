# Copyright (c) 2012-2017 Red Hat, Inc
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html

FROM registry.centos.org/che-stacks/centos-stack-base:latest

ENV CONTAINER_SCRIPTS_PATH=/home/user \
    ENABLED_COLLECTIONS="rh-dotnet20"

RUN sudo yum -y update && \
    sudo yum -y install centos-release-dotnet && \
    sudo yum -y install rh-dotnet20 && \
    sudo yum clean all 
    # cat /opt/rh/rh-dotnet20/enable >> /home/user/.bashrc

COPY scl_enable ${CONTAINER_SCRIPTS_PATH}/scl_enable
COPY container-entrypoint /usr/bin/

# ENV PATH /opt/rh/rh-dotnet20/root/usr/bin:/opt/rh/rh-dotnet20/root/usr/sbin${PATH:+:${PATH}}

# ENV BASH_ENV=/opt/rh/rh-dotnet20/enable \
#     ENV=/opt/rh/rh-dotnet20/enable

# When bash is started non-interactively, to run a shell script, for example it
# looks for this variable and source the content of this file. This will enable
# the SCL for all scripts without need to do 'scl enable'.                                                                                                                 
ENV BASH_ENV=${CONTAINER_SCRIPTS_PATH}/scl_enable \
    ENV=${CONTAINER_SCRIPTS_PATH}/scl_enable \
    PROMPT_COMMAND=". ${CONTAINER_SCRIPTS_PATH}/scl_enable"

ENTRYPOINT [ "container-entrypoint" ]

EXPOSE 5000
