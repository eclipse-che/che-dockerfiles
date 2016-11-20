FROM ubuntu:14.04
EXPOSE 4403 8000 8080 9876 22
RUN apt-get update && \
    apt-get -y install sudo openssh-server procps wget unzip mc curl subversion software-properties-common python-software-properties && \
    mkdir /var/run/sshd && \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd && \
    echo "%sudo ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    useradd -u 1000 -G users,sudo -d /home/user --shell /bin/bash -m user && \
    echo "secret\nsecret" | passwd user && \
    add-apt-repository ppa:git-core/ppa && \
    apt-get update && \
    sudo apt-get install git -y && \
    apt-get clean && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/*

USER user

LABEL che:server:8080:ref=tomcat8 che:server:8080:protocol=http che:server:8000:ref=tomcat8-debug che:server:8000:protocol=http che:server:9876:ref=codeserver che:server:9876:protocol=http


ENV MAVEN_VERSION=3.3.9 \
    JAVA_VERSION=8u102 \
    JAVA_BUILD=14 \
    JAVA_VERSION_PREFIX=1.8.0_102 \
    TOMCAT_HOME=/home/user/tomcat8 \
    TERM=xterm
ENV JAVA_HOME=/opt/jdk$JAVA_VERSION_PREFIX
ENV M2_HOME=/home/user/apache-maven-$MAVEN_VERSION
ENV PATH=$JAVA_HOME/bin:$M2_HOME/bin:$PATH

RUN mkdir /home/user/tomcat8 /home/user/apache-maven-$MAVEN_VERSION && \
  wget \
  --no-cookies \
  --no-check-certificate \
  --header "Cookie: oraclelicense=accept-securebackup-cookie" \
  -qO- \
  "http://download.oracle.com/otn-pub/java/jdk/$JAVA_VERSION-b$JAVA_BUILD/jdk-$JAVA_VERSION-linux-x64.tar.gz" | sudo tar -zx -C /opt/
RUN  wget -qO- "http://apache.ip-connect.vn.ua/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz" | tar -zx --strip-components=1 -C /home/user/apache-maven-$MAVEN_VERSION/ && \
    wget -qO- "http://archive.apache.org/dist/tomcat/tomcat-8/v8.0.24/bin/apache-tomcat-8.0.24.tar.gz" | tar -zx --strip-components=1 -C /home/user/tomcat8 && \
    rm -rf /home/user/tomcat8/webapps/*

ENV LANG en_GB.UTF-8
ENV LANG en_US.UTF-8
RUN sudo locale-gen en_US.UTF-8 && \
    svn --version && \
    sed -i 's/# store-passwords = no/store-passwords = yes/g' /home/user/.subversion/servers && \
    sed -i 's/# store-plaintext-passwords = no/store-plaintext-passwords = yes/g' /home/user/.subversion/servers

WORKDIR /projects

CMD sudo /usr/sbin/sshd -D && \
    tail -f /dev/null
