FROM debian:jessie
ENV DEBIAN_FRONTEND noninteractive
ENV CHE_MYSQL_PASSWORD=che
ENV CHE_MYSQL_DB=che_db
ENV CHE_MYSQL_USER=che
ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64
ENV PATH $JAVA_HOME/bin:$PATH
RUN apt-get update && \
    apt-get -y --no-install-recommends install mysql-server && \
    echo "deb http://ftp.debian.org/debian testing main" >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get -y install \
    openssh-server \
    sudo \
    procps \
    openjdk-8-jdk-headless \
    openjdk-8-source \
    wget \
    unzip \
    mc \
    locales \
    ca-certificates \
    curl \
    bash-completion \
    apache2 \
    php5 \
    php5-mhash \
    php5-mcrypt \
    php5-curl \
    php5-cli \
    php5-mysql \
    php5-gd \
    libapache2-mod-php5 \
    php5-cli \
    php5-json \
    php5-cgi \
    php5-sqlite && \
    sudo sed -i 's/\/var\/www\/html/\/projects/g'  /etc/apache2/sites-available/000-default.conf && \
    sudo sed -i 's/None/All/g' /etc/apache2/apache2.conf && \
    sudo sed -i 's/\/var\/www/\/projects/g'  /etc/apache2/apache2.conf && \
    echo "ServerName localhost" | sudo tee -a /etc/apache2/apache2.conf && \
    a2enmod rewrite && \
    curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer && \
    mkdir -p /home/user && \
    echo -e "MySQL password: $CHE_MYSQL_PASSWORD" >> /home/user/.mysqlrc && \
    echo -e "MySQL user    : $CHE_MYSQL_USER" >> /home/user/.mysqlrc && \
    echo -e "MySQL Database: $CHE_MYSQL_DB" >> /home/user/.mysqlrc && \
    apt-get clean && \
    apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/* && \
    sed -i.bak 's/127.0.0.1/0.0.0.0/g' /etc/mysql/my.cnf && \
    service mysql restart &&    mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%'; FLUSH PRIVILEGES;" && \
    service mysql restart && sudo mysql -uroot -e "CREATE USER '$CHE_MYSQL_USER'@'%' IDENTIFIED BY '"$CHE_MYSQL_PASSWORD"'" && \
    mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO '$CHE_MYSQL_USER'@'%' IDENTIFIED BY '"$CHE_MYSQL_PASSWORD"'; FLUSH PRIVILEGES;" && \
    mysql -uroot -e "CREATE DATABASE $CHE_MYSQL_DB;" && \
    mkdir /var/run/sshd && \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd && \
    echo "%sudo ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    useradd -u 1000 -G users,sudo -d /home/user --shell /bin/bash -m user && \
    usermod -p "*" user && \
    sudo echo -e "deb http://ppa.launchpad.net/git-core/ppa/ubuntu precise main\ndeb-src http://ppa.launchpad.net/git-core/ppa/ubuntu precise main" >> /etc/apt/sources.list.d/sources.list && \
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys A1715D88E1DF1F24 && \
    sudo apt-get update && sudo apt-get install git subversion -y && \
    apt-get clean && \
    apt-get -y autoremove \
    && apt-get -y clean \
    && rm -rf /var/lib/apt/lists/* && \
    echo "#! /bin/bash\n set -e\n sudo /usr/sbin/sshd -D &\n exec \"\$@\"" > /home/user/entrypoint.sh && chmod a+x /home/user/entrypoint.sh
ENV LANG C.UTF-8
USER user
RUN sudo localedef -i en_US -f UTF-8 en_US.UTF-8 && \
    sudo chmod -R 777 /home/user && \
    svn --version && \
    sed -i 's/# store-passwords = no/store-passwords = yes/g' /home/user/.subversion/servers && \
    sed -i 's/# store-plaintext-passwords = no/store-plaintext-passwords = yes/g' /home/user/.subversion/servers
EXPOSE 22 4403
WORKDIR /projects
ENTRYPOINT ["/home/user/entrypoint.sh"]
CMD tail -f /dev/null