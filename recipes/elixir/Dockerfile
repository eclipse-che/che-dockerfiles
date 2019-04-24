FROM eclipse/stack-base:ubuntu
ENV ERLANG_VERSION 21.3
ENV ELIXIR_VERSION 1.8

RUN git clone https://github.com/asdf-vm/asdf.git ~/.asdf && \
    cd ~/.asdf && \
    git checkout "$(git describe --abbrev=0 --tags)" && \
    sudo apt-get -y update && \
    sudo apt-get -y install \
    automake autoconf libreadline-dev \
    libncurses-dev libssl-dev libyaml-dev \
    libxslt-dev libffi-dev libtool unixodbc-dev \
    unzip curl make && \
    sudo apt-get -y clean && \
    sudo rm -rf /var/lib/apt/lists/* && \
    source ~/.bashrc && \
    asdf plugin-add erlang && \
    asdf install erlang ERLANG_VERSION && \
    asdf global erlang ERLANG_VERSION && \
    asdf plugin-add elixir && \
    asdf install elixir ELIXIR_VERSION && \
    asdf global elixir ELIXIR_VERSION
