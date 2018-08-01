# Copyright (c) 2012-2018 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#
# Contributors:
#   Red Hat, Inc. - initial API and implementation

FROM registry.centos.org/che-stacks/centos-nodejs
RUN sudo yum -y update && \
    sudo yum -y install gcc-c++ \
           gcc \
           glibc-devel \
           make \
           golang && \
    sudo yum clean all

ENV GOPATH /projects/.che
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
RUN sudo mkdir -p /projects/.che && \
    sudo chmod -R 777 /projects && \
    export GOPATH=/tmp/gopath && \
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
    echo -e "unset SUDO\nif sudo -n true > /dev/null 2>&1; then\nexport SUDO="sudo"\nfi\n if [ ! -d "/projects/.che/src" ]; then\necho "Copying GO LS Deps"\n\${SUDO} mkdir -p /projects/.che\n \${SUDO} cp -R /tmp/gopath/* /projects/.che/\nfi" > ${HOME}/gopath.sh && \
    chmod +x ${HOME}/gopath.sh && \
    cd ${HOME}/che/ls-golang && \
    npm i go-language-server@${GOLANG_LS_VERSION} && \
    for f in "${HOME}/che"; do \
        sudo chgrp -R 0 ${f} && \
        sudo chmod -R g+rwX ${f}; \
    done
EXPOSE 8080
CMD ${HOME}/gopath.sh & tail -f /dev/null
