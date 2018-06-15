# Copyright (c) 2012-2016 Codenvy, S.A.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
# Contributors:
# Codenvy, S.A. - initial API and implementation

FROM eclipse/stack-base:ubuntu
ENV CLANGD_VERSION="6.0"
RUN wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | sudo apt-key add - && \
    sudo apt-add-repository "deb http://apt.llvm.org/xenial/ llvm-toolchain-xenial-${CLANGD_VERSION} main" && \
    sudo apt-get update && \
    sudo apt-get install g++ gcc make gdb gdbserver clang-tools-${CLANGD_VERSION} -y && \
    sudo apt-get clean && \
    sudo apt-get -y autoremove && \
    sudo rm -rf /var/lib/apt/lists/* && \
    sudo ln -s /usr/bin/clangd-${CLANGD_VERSION} /usr/bin/clangd
