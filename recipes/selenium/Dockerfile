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

EXPOSE 8080 8000

# install xserver, blackbox, Chrome, Selenium webdriver


RUN cd /home/user && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add - && \
    wget -q http://chromedriver.storage.googleapis.com/2.24/chromedriver_linux64.zip && \
    unzip -q chromedriver_linux64.zip -d /home/user && rm chromedriver_linux64.zip

USER root

RUN echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list

USER user

RUN sudo apt-get update -qqy && \
  sudo apt-get -qqy install \
  google-chrome-stable \
  supervisor \
  x11vnc \
  xvfb \
  subversion \
  net-tools \
  blackbox \
  rxvt-unicode \
  xfonts-terminus && \
  sudo update-ca-certificates -f && \
  sudo sudo /var/lib/dpkg/info/ca-certificates-java.postinst configure && \
  sudo rm /etc/apt/sources.list.d/google-chrome.list \
  sudo rm -rf /var/lib/apt/lists/*

# download and install noVNC, configure Blackbox

RUN sudo mkdir -p /opt/noVNC/utils/websockify && \
    wget -qO- "http://github.com/kanaka/noVNC/tarball/master" | sudo tar -zx --strip-components=1 -C /opt/noVNC && \
    wget -qO- "https://github.com/kanaka/websockify/tarball/master" | sudo tar -zx --strip-components=1 -C /opt/noVNC/utils/websockify && \
    sudo mkdir -p /etc/X11/blackbox && \
    echo "[begin] (Blackbox) \n [exec] (Terminal)     {urxvt -fn "xft:Terminus:size=14"} \n \
    [exec] (Chrome)     {/opt/google/chrome/google-chrome} \n \
    [end]" | sudo tee -a /etc/X11/blackbox/blackbox-menu

ADD index.html  /opt/noVNC/
ADD supervisord.conf /opt/
EXPOSE 4444 6080 32745
ENV DISPLAY :20.0

ENV MAVEN_VERSION=3.3.9 \
    JAVA_VERSION=8u45 \
    JAVA_VERSION_PREFIX=1.8.0_45 \
    TOMCAT_HOME=/home/user/tomcat8

ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64 \
M2_HOME=/home/user/apache-maven-$MAVEN_VERSION

ENV PATH=$JAVA_HOME/bin:$M2_HOME/bin:$PATH

RUN mkdir /home/user/cbuild /home/user/tomcat8 /home/user/apache-maven-$MAVEN_VERSION && \
    wget -qO- "http://apache.ip-connect.vn.ua/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz" | tar -zx --strip-components=1 -C /home/user/apache-maven-$MAVEN_VERSION/
ENV TERM xterm

RUN wget -qO- "http://archive.apache.org/dist/tomcat/tomcat-8/v8.0.24/bin/apache-tomcat-8.0.24.tar.gz" | tar -zx --strip-components=1 -C /home/user/tomcat8 && \
    rm -rf /home/user/tomcat8/webapps/*

WORKDIR /projects

CMD if [ ! -z ${WEBDRIVER_VERSION+x} ]; then \
        wget -O /home/user/chromedriver_linux64.zip -q http://chromedriver.storage.googleapis.com/${WEBDRIVER_VERSION}/chromedriver_linux64.zip; \
        unzip -o -q /home/user/chromedriver_linux64.zip  -d /home/user; \
        rm /home/user/chromedriver_linux64.zip; \
    fi && \
    /usr/bin/supervisord -c /opt/supervisord.conf & \
    cd /home/user && sleep 3 && \
    /home/user/chromedriver --port=4444 --whitelisted-ips='' & \
    sleep 365d
