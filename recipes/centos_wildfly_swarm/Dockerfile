# Copyright (c) 2012-2017 Red Hat, Inc
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html

FROM registry.centos.org/che-stacks/centos-jdk8

MAINTAINER Dharmit Shah

EXPOSE 8080
LABEL che:server:8080:ref=wildfly che:server:8080:protocol=http

ARG SWARM_VERSION=2017.10.0

ADD configure_maven_and_deps.sh $HOME/

RUN sudo chmod +x ${HOME}/configure_maven_and_deps.sh

CMD ["sh","-c","${HOME}/configure_maven_and_deps.sh"]
