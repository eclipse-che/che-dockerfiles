# Copyright (c) 2012-2018 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#
# Contributors:
#   Red Hat, Inc. - initial API and implementation

FROM eclipse/stack-base:debian

ENV ANDROID_HOME=/home/user/android-sdk-linux \
    FLUTTER_HOME=/home/user/flutter \
    PATH=/usr/lib/dart/bin:$FLUTTER_HOME/bin:$M2_HOME/bin:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$PATH \
    MAVEN_VERSION=3.5.3
ENV M2_HOME=/home/user/apache-maven-$MAVEN_VERSION

RUN sudo sh -c 'curl https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -' && \
    sudo sh -c 'curl https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list' && \
    sudo apt-get -y update && \
    sudo apt-get -y install  build-essential dart libkrb5-dev gcc make && \
    sudo apt-get clean && \
    sudo apt-get -y autoremove && \
    sudo apt-get -y clean && \
    sudo rm -rf /var/lib/apt/lists/*

RUN cd ${HOME} && wget -qO- "https://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz" | \
        tar -zx --strip-components=1 -C /home/user/apache-maven-$MAVEN_VERSION/;

# TODO: Flutter requires a VNC to be seen if the UI works

RUN cd /home/user && wget --output-document=android-sdk.tgz --quiet http://dl.google.com/android/android-sdk_r24.4.1-linux.tgz && tar -xvf android-sdk.tgz && rm android-sdk.tgz && \
    echo y | android update sdk --all --force --no-ui --filter platform-tools,build-tools-21.1.1,android-21,sys-img-armeabi-v7a-android-21 && \
    echo "no" | android create avd \
                --name che \
                --target android-21 \
                --abi armeabi-v7a && \
    for f in "${HOME}/.android" "${HOME}/android-sdk-linux"; do \
      sudo chgrp -R 0 ${f} && \
      sudo chmod -R g+rwX ${f}; \
    done;

RUN cd /home/user && wget -O flutter_sdk.tar.xz https://storage.googleapis.com/flutter_infra/releases/stable/linux/flutter_linux_v1.0.0-stable.tar.xz \
    && tar -xvf flutter_sdk.tar.xz && rm flutter_sdk.tar.xz;

EXPOSE 1337 3000 4200 5000 9000 8003
LABEL che:server:8003:ref=angular che:server:8003:protocol=http che:server:3000:ref=node-3000 che:server:3000:protocol=http che:server:9000:ref=node-9000 che:server:9000:protocol=http