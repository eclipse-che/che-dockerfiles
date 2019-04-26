 FROM eclipse/stack-base:ubuntu 

 RUN wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && \ 
     sudo dpkg -i erlang-solutions_1.0_all.deb && \ 
     sudo apt-get -y update && \ 
     sudo apt-get --allow-unauthenticated  install -y esl-erlang && \ 
     sudo apt-get install -y elixir && \ 
     sudo apt-get -y clean && \ 
     sudo rm -rf /var/lib/apt/lists/* && \ 
     rm -rf erlang-solutions_1.0_all.deb 