FROM eclipse/stack-base:ubuntu

ENV ASDF_HOME $HOME/.asdf/
ENV ERLANG_VERSION 21.3
ENV ELIXIR_VERSION 1.8

RUN git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.7.1 && \
    echo "$HOME/.asdf/asdf.sh" >> ~/.bashrc && \
    echo "$HOME/.asdf/completions/asdf.bash" >> ~/.bashrc && \
    sudo apt-get -y update && \
    sudo apt-get -y install \
    automake autoconf libreadline-dev \
    libncurses-dev libssl-dev libyaml-dev \
    libxslt-dev libffi-dev libtool unixodbc-dev \
    unzip curl make && \
    sudo apt-get -y clean && \
    sudo rm -rf /var/lib/apt/lists/* && \
    /bin/bash -c "source $ASDF_HOME/asdf.sh && \
                  source $ASDF_HOME/completions/asdf.bash && \
                  asdf plugin-add erlang && \
                  asdf plugin-add elixir && \
                  asdf install erlang $ERLANG_VERSION && \
                  asdf global erlang $ERLANG_VERSION && \
                  asdf install elixir $ELIXIR_VERSION && \
                  asdf global elixir $ELIXIR_VERSION"
