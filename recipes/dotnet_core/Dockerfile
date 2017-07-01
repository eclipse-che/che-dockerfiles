# Copyright (c) 2012-2016 Codenvy, S.A.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
# Contributors:
# Abel García Dorta <mercuriete@gmail.com> 
# Roger S <narayanroger@gmail.com>

FROM eclipse/debian_jdk8
RUN sudo curl -L -o dotnet.tar.gz https://go.microsoft.com/fwlink/?LinkID=809130 && \
    sudo apt-get update && \
    sudo apt-get -y install libunwind8 gettext && \
    sudo mkdir -p /opt/dotnet && \
    sudo tar zxf dotnet.tar.gz -C /opt/dotnet && \
    sudo rm dotnet.tar.gz && \
    sudo ln -s /opt/dotnet/dotnet /usr/local/bin && \
    curl -sL https://deb.nodesource.com/setup_7.x | sudo -E bash - && \
    sudo apt-get install nodejs -y && \
    sudo npm install -g yo bower grunt-cli gulp && \
    sudo npm install -g generator-aspnet
EXPOSE 3000 5000 8000 8080
