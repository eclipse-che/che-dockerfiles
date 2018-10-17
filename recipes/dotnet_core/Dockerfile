# Copyright (c) 2012-2018 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#
# Contributors:
#   Red Hat, Inc. - initial API and implementation

FROM eclipse/stack-base:ubuntu
ENV OMISHARP_VERSION="1.31.1"
ENV OMNISHARP_DOWNLOAD_URL="https://github.com/OmniSharp/omnisharp-roslyn/releases/download/v${OMISHARP_VERSION}/omnisharp-linux-x64.tar.gz"
ENV CSHARP_LS_DIR=${HOME}/che/ls-csharp
RUN sudo apt-get update && \
    sudo apt-key adv --keyserver packages.microsoft.com --recv-keys EB3E94ADBE1229CF && \
    sudo apt-key adv --keyserver packages.microsoft.com --recv-keys 52E16F86FEE04B979B07E28DB02C46DF417A0893 && \
    sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-bionic-prod bionic main" > /etc/apt/sources.list.d/dotnetdev.list' && \
    sudo apt-get update && \
    sudo apt-get install -y \
    dotnet-sdk-2.1.105 && \
    sudo apt-get -y clean && \
    sudo rm -rf /var/lib/apt/lists/* && \
    mkdir -p ${CSHARP_LS_DIR}

RUN cd ${CSHARP_LS_DIR} && wget https://github.com/OmniSharp/omnisharp-roslyn/releases/download/v1.31.1/omnisharp-linux-x64.tar.gz && \
    tar -xvf omnisharp-linux-x64.tar.gz --strip 1 && \
    sudo chgrp -R 0 ${HOME} && \
    sudo chmod -R g+rwX ${HOME}
EXPOSE 5000 9000
CMD tail -f /dev/null
