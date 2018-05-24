FROM eclipse/stack-base:ubuntu
RUN curl -sL https://deb.nodesource.com/setup_6.x | sudo bash - && \
    sudo apt-get update && sudo apt-get install -y --no-install-recommends \
    g++ \
    gcc \
    libc6-dev \
    make \
    nodejs \
    && sudo rm -rf /var/lib/apt/lists/*
ENV GOLANG_VERSION 1.10.2
ENV GOLANG_LS_VERSION="0.1.7"
ENV goRelArch linux-amd64
ENV GOLANG_DOWNLOAD_URL https://golang.org/dl/go${GOLANG_VERSION}.${goRelArch}.tar.gz
ENV GOPATH /projects/.che
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
RUN sudo curl -fsSL "$GOLANG_DOWNLOAD_URL" -o golang.tar.gz \
    && sudo tar -C /usr/local -xzf golang.tar.gz \
    && sudo rm golang.tar.gz && \
    sudo mkdir -p "$GOPATH/src" "$GOPATH/bin" && sudo chmod -R 777 "$GOPATH" && \
    go get -v github.com/nsf/gocode && \
    go get -v github.com/uudashr/gopkgs/cmd/gopkgs && \
    go get -v github.com/ramya-rao-a/go-outline && \
    go get -v github.com/acroca/go-symbols && \
    go get -v golang.org/x/tools/cmd/guru && \
    go get -v golang.org/x/tools/cmd/gorename && \
    go get -v github.com/fatih/gomodifytags && \
    go get -v github.com/haya14busa/goplay/cmd/goplay && \
    go get -v github.com/josharian/impl && \
    go get -v github.com/tylerb/gotype-live && \
    go get -v github.com/rogpeppe/godef && \
    go get -v golang.org/x/tools/cmd/godoc && \
    go get -v github.com/zmb3/gogetdoc && \
    go get -v golang.org/x/tools/cmd/goimports && \
    go get -v sourcegraph.com/sqs/goreturns && \
    go get -v github.com/golang/lint/golint && \
    go get -v github.com/cweill/gotests/... && \
    go get -v github.com/alecthomas/gometalinter && \
    go get -v honnef.co/go/tools/... && \
    go get -v github.com/sourcegraph/go-langserver && \
    go get -v github.com/derekparker/delve/cmd/dlv && \
    mkdir -p ${HOME}/che/ls-golang && \
    cd ${HOME}/che/ls-golang && \
    npm i go-language-server@${GOLANG_LS_VERSION} && \
    sudo chgrp -R 0 ${HOME}/che && \
    sudo chmod -R g+rwX ${HOME}/che
EXPOSE 8080
