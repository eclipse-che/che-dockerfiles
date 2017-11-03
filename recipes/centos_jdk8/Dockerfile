# Copyright (c) 2012-2016 Codenvy, S.A.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
# Contributors:
# Codenvy, S.A. - initial API and implementation

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

ENV MAVEN_OPTS=$JAVA_OPTS

USER user

ADD ./contrib/run.sh $HOME/run.sh

RUN mkdir -p $HOME/.m2 && \
    mkdir /home/user/tomcat8 && \
    wget -qO- "http://archive.apache.org/dist/tomcat/tomcat-8/v8.0.24/bin/apache-tomcat-8.0.24.tar.gz" | tar -zx --strip-components=1 -C /home/user/tomcat8 && \
    rm -rf /home/user/tomcat8/webapps/* && \
    echo "export MAVEN_OPTS=\$JAVA_OPTS" >> /home/user/.bashrc && \
    sudo chmod a+x $HOME/run.sh

ADD ./contrib/settings.xml $HOME/.m2/settings.xml

# override the default CMD form base image to allow configuring maven settings
CMD ["sh","-c","${HOME}/run.sh"]
