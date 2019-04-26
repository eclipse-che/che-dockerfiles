FROM eclipse/stack-base:ubuntu 

ENV ERLANG_VERSION 1.0

RUN wget https://packages.erlang-solutions.com/erlang-solutions_"$ERLANG_VERSION"_all.deb && \ 
    sudo dpkg -i erlang-solutions_"$ERLANG_VERSION"_all.deb && \ 
    sudo apt-get -y update && \ 
    sudo apt-get --allow-unauthenticated  install -y esl-erlang && \ 
    sudo apt-get install -y elixir && \ 
    sudo apt-get -y clean && \ 
    sudo rm -rf /var/lib/apt/lists/* && \ 
    rm -rf erlang-solutions_"$ERLANG_VERSION"_all.deb 
