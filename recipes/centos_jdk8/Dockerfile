# Copyright (c) 2012-2018 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#
# Contributors:
#   Red Hat, Inc. - initial API and implementation

FROM registry.centos.org/che-stacks/centos-stack-base
EXPOSE 4403 8080 8000 9876 22

LABEL che:server:8080:ref=tomcat8 che:server:8080:protocol=http che:server:8000:ref=tomcat8-debug che:server:8000:protocol=http che:server:9876:ref=codeserver che:server:9876:protocol=http

ENV M2_HOME=/opt/rh/rh-maven33/root/usr/share/maven \
    TOMCAT_HOME=/home/user/tomcat8 \
    TERM=xterm
ENV PATH=$M2_HOME/bin:$PATH

RUN sudo yum -y update && \
    sudo yum -y install rh-maven33 && \
    sudo yum clean all && \
    cat /opt/rh/rh-maven33/enable >> /home/user/.bashrc

USER user

ADD ./contrib/run.sh $HOME/run.sh

RUN mkdir -p $HOME/.m2 && \
    mkdir /home/user/tomcat8 && \
    wget -qO- "http://archive.apache.org/dist/tomcat/tomcat-8/v8.0.24/bin/apache-tomcat-8.0.24.tar.gz" | tar -zx --strip-components=1 -C /home/user/tomcat8 && \
    rm -rf /home/user/tomcat8/webapps/* && \
    sudo chmod a+x $HOME/run.sh && \
    sudo mkdir -p /home/user/jdtls/data && \
    sudo chgrp -R 0 ${HOME} && \
    sudo chmod -R g+rwX ${HOME}

ADD ./contrib/settings.xml $HOME/.m2/settings.xml
RUN sudo chgrp -R 0 /home/user && \
    sudo chmod -R g+rwX /home/user


# override the default CMD form base image to allow configuring maven settings
CMD ["sh","-c","${HOME}/run.sh"]
