FROM eclipse/php

RUN sudo apt-get update && \
    sudo apt-get --no-install-recommends -y -q install php7.0-zip -y && \
    sudo composer global require "laravel/installer" && \
    sudo apt-get -y clean && \
    sudo rm -rf /var/lib/apt/lists/*
ENV PATH /home/user/.composer/vendor/bin:$PATH

