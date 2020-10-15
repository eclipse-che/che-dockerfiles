FROM eclipse/stack-base:ubuntu
RUN sudo apt-get purge -y python.* &&   sudo apt-get update &&   sudo apt-get install -y --no-install-recommends \
    autoconf \
    automake \
    bzip2 \
    file \
    g++ \
    gcc \
    imagemagick \
    libbz2-dev \
    libc6-dev \
    libcurl4-openssl-dev libdb-dev libevent-dev libffi-dev libgdbm-dev libgeoip-dev libglib2.0-dev libjpeg-dev \
    libkrb5-dev liblzma-dev libmagickcore-dev libmagickwand-dev libmysqlclient-dev libncurses-dev libpng-dev \
    libpq-dev libreadline-dev libsqlite3-dev libssl-dev libtool libwebp-dev libxml2-dev libxslt-dev libyaml-dev make patch xz-utils zlib1g-dev && \
    sudo apt-get install -y python3 python3-pip
RUN cd /usr/bin && sudo ln -s python3 python && sudo ln -s pip3 pip
RUN sudo pip install --upgrade pip && \
    sudo pip install --no-cache-dir virtualenv && \
    sudo pip install --upgrade setuptools && \
    sudo pip install 'python-language-server[all]'
EXPOSE 8080
