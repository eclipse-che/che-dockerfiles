ARG ELIXIR_VERSION="1.8"
FROM  elixir:${ELIXIR_VERSION} as elixir_image

FROM eclipse/stack-base:ubuntu 
ARG ERLANG_VERSION=1.0

COPY --from=elixir_image /usr/local/src/elixir /usr/local/src/elixir
RUN wget https://packages.erlang-solutions.com/erlang-solutions_"$ERLANG_VERSION"_all.deb \
&& sudo dpkg -i erlang-solutions_"$ERLANG_VERSION"_all.deb \
&& sudo apt-get -y update \
&& sudo apt-get --allow-unauthenticated  install -y esl-erlang make\
&& sudo rm erlang-solutions_"$ERLANG_VERSION"_all.deb \
&& cd /usr/local/src/elixir \
&& sudo make -s install clean \
&& sudo apt-get -y clean \
&& sudo rm -rf /var/lib/apt/lists/*
