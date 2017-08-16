# Copyright (c) 2012-2017 Codenvy, S.A.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
# Contributors:
# Codenvy, S.A. - initial API and implementation

FROM eclipse/stack-base:ubuntu
RUN curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg && \
    sudo mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg && \
    sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-xenial-prod xenial main" > /etc/apt/sources.list.d/dotnetdev.list' && \
    wget -qO- https://deb.nodesource.com/setup_7.x | sudo -E bash - && \
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF && \
    echo "deb http://download.mono-project.com/repo/ubuntu beta-xenial main" | sudo tee /etc/apt/sources.list.d/mono-official-beta.list && \
    sudo apt-get update && \
    sudo apt-get install -y \
    dotnet-sdk-2.0.0 \
    mono-devel \
    nodejs && \
    sudo apt-get -y clean && \
    sudo rm -rf /var/lib/apt/lists/*
EXPOSE 5000 9000
CMD tail -f /dev/null