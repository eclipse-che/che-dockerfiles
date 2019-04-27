FROM eclipse/stack-base:ubuntu 
ARG ELIXIR_VERSION="1.8.1"
ARG ERLANG_VERSION="1.0"
ARG DEBIAN_FRONTEND=noninteractive

USER root

RUN wget -q https://packages.erlang-solutions.com/erlang-solutions_"$ERLANG_VERSION"_all.deb \
&& apt-get -qq install ./erlang-solutions_"$ERLANG_VERSION"_all.deb \
&& apt-get -qq update \
&& apt-get -qq --allow-unauthenticated  install esl-erlang \
&& wget -q https://packages.erlang-solutions.com/erlang/elixir/FLAVOUR_2_download/elixir_"$ELIXIR_VERSION"-2~ubuntu~xenial_amd64.deb \
&& apt-get -qq install ./elixir_"$ELIXIR_VERSION"-2~ubuntu~xenial_amd64.deb \
&& apt-get -qq update \
&& apt-get -qq clean \
&& rm -rf /var/lib/apt/lists \
&& rm -rf /projects/*.deb

USER user
