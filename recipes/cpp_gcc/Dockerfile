# Copyright (c) 2012-2018 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#
# Contributors:
#   Red Hat, Inc. - initial API and implementation

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
