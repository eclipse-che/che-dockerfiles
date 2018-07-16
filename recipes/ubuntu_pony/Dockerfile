FROM eclipse/stack-base:ubuntu

ENV PONY_PACKAGE_VERSION 0.1.3-0ppa1~xenial

RUN sudo add-apt-repository ppa:ponylang/ponylang
RUN sudo apt-get update
RUN sudo apt-get install -y pony-stable=${PONY_PACKAGE_VERSION}

EXPOSE 8080
