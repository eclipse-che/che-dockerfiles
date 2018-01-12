# Copyright (c) 2012-2017 Codenvy, S.A.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
# Contributors:
# Codenvy, S.A. - initial API and implementation

FROM eclipse/stack-base:ubuntu
ENV OMISHARP_CLIENT_VERSION=7.1.3
ENV CSHARP_LS_DIR=$HOME/che/ls-csharp
RUN sudo apt-get update && sudo apt-get install apt-transport-https -y && \
    curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > ~/microsoft.gpg && \
    sudo mv ~/microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg && \
    sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-xenial-prod xenial main" > /etc/apt/sources.list.d/dotnetdev.list' && \
    wget -qO- https://deb.nodesource.com/setup_8.x | sudo -E bash - && \
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF && \
    echo "deb http://download.mono-project.com/repo/ubuntu beta-xenial main" | sudo tee /etc/apt/sources.list.d/mono-official-beta.list && \
    sudo apt-get update && \
    sudo apt-get install -y \
    dotnet-sdk-2.0.2 \
    mono-devel \
    nodejs && \
    sudo apt-get -y clean && \
    sudo rm -rf /var/lib/apt/lists/* && \
    mkdir -p $HOME/che/ls-csharp && \
    echo "nodejs $HOME/che/ls-csharp/node_modules/omnisharp-client/languageserver/server.js" > $CSHARP_LS_DIR/launch.sh && \
    chmod +x $CSHARP_LS_DIR/launch.sh && \
    cd $CSHARP_LS_DIR && \
    npm i omnisharp-client@$OMISHARP_CLIENT_VERSION
EXPOSE 5000 9000
CMD tail -f /dev/null
