# Copyright (c) 2012-2016 Codenvy, S.A.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
# Contributors:
# Codenvy, S.A. - initial API and implementation

FROM eclipse/stack-base:ubuntu

ENV TERM xterm
ENV ANDROID_HOME=/home/user/android-sdk-linux
ENV MAVEN_VERSION=3.3.9
ENV PATH=$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$PATH

LABEL che:server:6080:ref=VNC che:server:6080:protocol=http

RUN sudo dpkg --add-architecture i386 && \
    sudo apt-get update && sudo apt-get install -y --force-yes expect libswt-gtk-3-java lib32z1 lib32ncurses5 lib32stdc++6 supervisor x11vnc xvfb net-tools \
    blackbox rxvt-unicode xfonts-terminus sudo openssh-server procps && \
    mkdir /home/user/apache-maven-$MAVEN_VERSION && \
    wget -qO- "https://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz" | tar -zx --strip-components=1 -C /home/user/apache-maven-$MAVEN_VERSION/ && \
    cd /home/user && wget --output-document=android-sdk.tgz --quiet http://dl.google.com/android/android-sdk_r24.4.1-linux.tgz && tar -xvf android-sdk.tgz && rm android-sdk.tgz && \
    sudo apt-get clean && \
    sudo apt-get -y autoremove && \
    sudo rm -rf /var/lib/apt/lists/* && \
    echo y | android update sdk --all --force --no-ui --filter platform-tools,build-tools-21.1.1,android-21,sys-img-armeabi-v7a-android-21 && \
    echo "no" | android create avd \
                --name che \
                --target android-21 \
                --abi armeabi-v7a && \
    sudo mkdir -p /opt/noVNC/utils/websockify && \
    wget -qO- "http://github.com/kanaka/noVNC/tarball/master" | sudo tar -zx --strip-components=1 -C /opt/noVNC && \
    wget -qO- "https://github.com/kanaka/websockify/tarball/master" | sudo tar -zx --strip-components=1 -C /opt/noVNC/utils/websockify && \
    sudo mkdir -p /etc/X11/blackbox && \
    echo "[begin] (Blackbox) \n [exec] (Terminal)     {urxvt -fn "xft:Terminus:size=12"} \n \
          [exec] (Emulator) {emulator64-arm -avd che} \n \
          [end]" | sudo tee -a /etc/X11/blackbox/blackbox-menu
ADD index.html /opt/noVNC/
ADD supervisord.conf /opt/
EXPOSE 4403 6080 22
CMD /usr/bin/supervisord -c /opt/supervisord.conf && tail -f /dev/null
