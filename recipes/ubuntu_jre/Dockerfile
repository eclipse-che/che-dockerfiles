# Copyright (c) 2012-2016 Codenvy, S.A.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
# Contributors:
# Codenvy, S.A. - initial API and implementation

FROM ubuntu:14.04

ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH
RUN apt-get update && \
    apt-get -y install \
    openssh-server \
    sudo \
    procps \
    wget \
    unzip \
    mc \
    ca-certificates \
    curl \
    software-properties-common \
    python-software-properties && \
    mkdir /var/run/sshd && \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd && \
    echo "%sudo ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    useradd -u 1000 -G users,sudo -d /home/user --shell /bin/bash -m user && \
    echo "secret\nsecret" | passwd user && \
    add-apt-repository ppa:git-core/ppa && \
    add-apt-repository ppa:openjdk-r/ppa && \
    apt-get update && \
    sudo apt-get install git subversion -y && \
    apt-get clean && \
    apt-get -y autoremove && \
    sudo apt-get install openjdk-8-jdk -y && \
    sudo update-ca-certificates -f && \
    sudo sudo /var/lib/dpkg/info/ca-certificates-java.postinst configure && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/* && \
    echo "#! /bin/bash\n set -e\n sudo /usr/sbin/sshd -D &\n exec \"\$@\"" > /home/user/entrypoint.sh && chmod a+x /home/user/entrypoint.sh

ENV LANG en_GB.UTF-8
ENV LANG en_US.UTF-8
USER user
RUN sudo locale-gen en_US.UTF-8 && \
    svn --version && \
    cd /home/user && ls -la && \
    sed -i 's/# store-passwords = no/store-passwords = yes/g' /home/user/.subversion/servers && \
    sed -i 's/# store-plaintext-passwords = no/store-plaintext-passwords = yes/g' /home/user/.subversion/servers
EXPOSE 22 4403
WORKDIR /projects
ENTRYPOINT ["/home/user/entrypoint.sh"]
CMD tail -f /dev/null
