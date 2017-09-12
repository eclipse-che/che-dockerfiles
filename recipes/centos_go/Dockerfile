# Copyright (c) 2012-2017 Red Hat, Inc
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html

FROM registry.centos.org/che-stacks/centos-stack-base
EXPOSE 8080

ENV GOPATH=/go \
    PATH=$GOPATH/bin:/usr/local/go/bin:$PATH

RUN sudo yum -y update && \
    sudo yum -y install gcc-c++ \
           gcc \
           glibc-devel \
           make \
           golang && \
    sudo yum clean all && \
    sudo mkdir -p "$GOPATH/src" "$GOPATH/bin" && sudo chmod -R 777 "$GOPATH"
