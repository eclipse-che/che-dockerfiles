FROM eclipse/stack-base:ubuntu
EXPOSE 4403 8000 8080 9876 22

LABEL che:server:8080:ref=tomcat9 che:server:8080:protocol=http che:server:8000:ref=tomcat9-debug che:server:8000:protocol=http che:server:9876:ref=codeserver che:server:9876:protocol=http

ENV MAVEN_VERSION=3.6.0 \
    JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64 \
    TOMCAT_HOME=/home/user/tomcat9 \
    TERM=xterm
ENV M2_HOME=/home/user/apache-maven-$MAVEN_VERSION
ENV PATH=$JAVA_HOME/bin:$M2_HOME/bin:$PATH

COPY open-jdk-source-file-location /open-jdk-source-file-location

RUN sudo apt-get install openjdk-11-jdk-headless=11.0.1+13-3ubuntu3.19.04.1 openjdk-11-source=11.0.1+13-3ubuntu3.19.04.1 -y && \
    sudo sudo /var/lib/dpkg/info/ca-certificates-java.postinst configure && \
    mkdir /home/user/tomcat9 /home/user/apache-maven-$MAVEN_VERSION && \
    wget -qO- "http://apache.ip-connect.vn.ua/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz" | tar -zx --strip-components=1 -C /home/user/apache-maven-$MAVEN_VERSION/ && \
    wget -qO- "http://archive.apache.org/dist/tomcat/tomcat-9/v9.0.14/bin/apache-tomcat-9.0.14.tar.gz" | tar -zx --strip-components=1 -C /home/user/tomcat9 && \
    rm -rf /home/user/tomcat9/webapps/* && \
    sudo mkdir -p /home/user/.m2 && \
    sudo mkdir -p /home/user/jdtls/data && \
    sudo chgrp -R 0 ${HOME} && \
    sudo chmod -R g+rwX ${HOME}
