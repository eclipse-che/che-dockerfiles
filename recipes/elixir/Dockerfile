FROM eclipse/stack-base:ubuntu 

ARG ELIXIR_VERSION="1.8.1"
ARG ERLANG_VERSION="1.0"

RUN wget https://packages.erlang-solutions.com/erlang-solutions_"$ERLANG_VERSION"_all.deb \
&& sudo dpkg -i erlang-solutions_"$ERLANG_VERSION"_all.deb \
&& sudo apt-get -y update \
&& sudo apt-get --allow-unauthenticated  install -y esl-erlang \

&& wget https://packages.erlang-solutions.com/erlang/elixir/FLAVOUR_2_download/elixir_"$ELIXIR_VERSION"-2~ubuntu~xenial_amd64.deb \
&& sudo dpkg -i elixir_"$ELIXIR_VERSION"-2~ubuntu~xenial_amd64.deb \
&& sudo apt-get --allow-unauthenticated  install -y elixir \

&& sudo apt-get -y clean \
&& sudo rm -rf /var/lib/apt/lists
