# Copyright (c) 2012-2016 Codenvy, S.A.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
# Contributors:
# Abel García Dorta <mercuriete@gmail.com> 
# Roger S <narayanroger@gmail.com>

FROM eclipse/debian_jre
RUN sudo apt-get update \
    && sudo apt-get install -y --no-install-recommends \
        libc6 \
        libcurl3 \
        libgcc1 \
        libgssapi-krb5-2 \0
        libicu52 \
        liblttng-ust0 \
        libssl1.0.0 \
        libstdc++6 \
        libunwind8 \
        libuuid1 \
        zlib1g \
    && sudo rm -rf /var/lib/apt/lists/*

# Install .NET Core SDK
ENV DOTNET_SDK_VERSION 1.0.4
ENV DOTNET_SDK_DOWNLOAD_URL https://dotnetcli.blob.core.windows.net/dotnet/Sdk/$DOTNET_SDK_VERSION/dotnet-dev-debian-x64.$DOTNET_SDK_VERSION.tar.gz

RUN sudo curl -SL $DOTNET_SDK_DOWNLOAD_URL --output dotnet.tar.gz \
    && sudo mkdir -p /usr/share/dotnet \
    && sudo tar -zxf dotnet.tar.gz -C /usr/share/dotnet \
    && sudo rm dotnet.tar.gz \
    && sudo ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet

# Trigger the population of the local package cache
ENV NUGET_XMLDOC_MODE skip
RUN mkdir ~/warmup \
    && cd ~/warmup \
    && dotnet new \
    && cd .. \
    && rm -rf warmup \
    && sudo rm -rf /tmp/NuGetScratch

RUN curl -sL https://deb.nodesource.com/setup_7.x | sudo -E bash -
RUN sudo apt-get install nodejs -y
RUN sudo npm install -g yo bower grunt-cli gulp
RUN sudo npm install -g generator-aspnet