# Copyright (c) 2012-2016 Codenvy, S.A.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
# Contributors:
# Abel García Dorta <mercuriete@gmail.com> 
# Roger Narayan <narayanroger@gmail.com>

FROM codenvy/ubuntu_jre

MAINTAINER mercuriete@gmail.com

RUN echo "deb [arch=amd64] http://apt-mo.trafficmanager.net/repos/dotnet/ trusty main" | sudo tee --append /etc/apt/sources.list.d/dotnetdev.list && \
    sudo apt-key adv --keyserver apt-mo.trafficmanager.net --recv-keys 417A0893 &&\
    sudo apt-get update && \
    sudo apt-get install dotnet-dev-1.0.0-preview2-003121 -y && \
    sudo apt-get clean && \
    sudo apt-get -y autoremove && \
    sudo apt-get -y clean && \
    sudo rm -rf /var/lib/apt/lists/*
    
RUN curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
RUN sudo apt-get install nodejs -y
RUN sudo npm install -g yo bower grunt-cli gulp
RUN sudo npm install -g generator-aspnet

ENV LANG C.UTF-8
EXPOSE 5000
LABEL che:server:5000:ref=dot.net.server che:server:5000:protocol=http
WORKDIR /projects
CMD tail -f /dev/null
