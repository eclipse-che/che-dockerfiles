FROM eclipse/stack-base:debian

ARG HUGO_VERSION=0.54.0

RUN wget https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-64bit.deb && \
    sudo dpkg -i hugo_${HUGO_VERSION}_Linux-64bit.deb && \
    rm hugo_${HUGO_VERSION}_Linux-64bit.deb

EXPOSE 1313
