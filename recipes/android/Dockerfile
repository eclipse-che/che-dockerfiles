# Copyright (c) 2012-2018 Red Hat, Inc.
# This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v2.0
# which is available at http://www.eclipse.org/legal/epl-2.0.html
#
# SPDX-License-Identifier: EPL-2.0
#
# Contributors:
#   Red Hat, Inc. - initial API and implementation

FROM eclipse/stack-base:centos

ENV DISPLAY=:1 \
    VNC_PORT=5901 \
    NO_VNC_PORT=6901 \
    STARTUPDIR=/dockerstartup \
    INST_SCRIPTS=/headless/install \
    NO_VNC_HOME=/headless/noVNC \
    TERM=xterm \
    SHELL=/bin/bash \
    VNC_COL_DEPTH=24 \
    VNC_RESOLUTION=1280x1024 \
    VNC_PW=vncpassword \
    VNC_VIEW_ONLY=false \
    LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8' \
    ANDROID_HOME=/home/user/android-sdk-linux \
    PATH=$M2_HOME/bin:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$PATH \
    MAVEN_VERSION=3.5.3
ENV M2_HOME=/home/user/apache-maven-$MAVEN_VERSION
ENV PATH=$M2_HOME/bin:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$PATH


EXPOSE $VNC_PORT $NO_VNC_PORT

RUN sudo mkdir -p ${NO_VNC_HOME}/utils/websockify && \
    sudo wget -qO- https://github.com/kanaka/noVNC/archive/v0.6.1.tar.gz | sudo tar xz --strip 1 -C ${NO_VNC_HOME} && \
    sudo wget -qO- https://github.com/kanaka/websockify/archive/v0.8.0.tar.gz | sudo tar xz --strip 1 -C ${NO_VNC_HOME}/utils/websockify && \
    sudo chmod +x -v ${NO_VNC_HOME}/utils/*.sh && \
    sudo ln -s ${NO_VNC_HOME}/vnc_auto.html ${NO_VNC_HOME}/index.html && \
    mkdir -p ${HOME}/apache-maven-3.5.3 && \
    cd ${HOME} && wget -qO- "https://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz" | \
                  tar -zx --strip-components=1 -C /home/user/apache-maven-$MAVEN_VERSION/ && \
    sudo yum -y install epel-release && \
    sudo yum -y update && \
    sudo yum -y install -y which net-tools tigervnc-server nss_wrapper gettext \
                           glibc.i686 glibc-devel.i686 libstdc++.i686 \
                           zlib-devel.i686 ncurses-devel.i686 libX11-devel.i686 \
                           libXrender.i686 libXrandr.i686 && \
    sudo yum --enablerepo=epel -y -x gnome-keyring --skip-broken groups install "Xfce" && \
    sudo yum -y groups install "Fonts" && \
    sudo yum erase -y *power* *screensaver* && \
    sudo rm /etc/xdg/autostart/xfce-polkit* && \
    sudo yum clean all
USER root
RUN /bin/dbus-uuidgen > /etc/machine-id
USER user

ADD Desktop ${HOME}/Desktop
ADD vnc_start.sh ${STARTUPDIR}/vnc_start.sh
RUN sudo mkdir -p /dockerstartup && \
    for f in "${STARTUPDIR}" "/headless" "${HOME}"; do \
           sudo chgrp -R 0 ${f} && \
           sudo chmod -R g+rwX ${f}; \
        done && \
    sudo chmod +x ${STARTUPDIR}/vnc_start.sh && \
    sudo chmod -R 777 ${STARTUPDIR} && \
    sudo chmod +x ${HOME}/Desktop/*.desktop && \
    cd /home/user && wget --output-document=android-sdk.tgz --quiet http://dl.google.com/android/android-sdk_r24.4.1-linux.tgz && tar -xvf android-sdk.tgz && rm android-sdk.tgz && \
    echo y | android update sdk --all --force --no-ui --filter platform-tools,build-tools-21.1.1,android-21,sys-img-armeabi-v7a-android-21 && \
    echo "no" | android create avd \
                --name che \
                --target android-21 \
                --abi armeabi-v7a && \
    for f in "${HOME}/.android" "${HOME}/android-sdk-linux"; do \
      sudo chgrp -R 0 ${f} && \
      sudo chmod -R g+rwX ${f}; \
    done
CMD /dockerstartup/vnc_start.sh --wait
