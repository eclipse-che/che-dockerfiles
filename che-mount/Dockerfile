# Copyright (c) 2012-2016 Codenvy, S.A.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
#
# Contributors:
#   Tyler Jewell - Initial implementation
#
# build:
#   docker build -t eclipse/che-mount .
#
# use:
#  On linux:
#  docker run --rm -it --cap-add SYS_ADMIN --device /dev/fuse
#             --name che-mount
#             -v ${HOME}/.ssh:${HOME}/.ssh
#             -v ${HOME}/.unison:${HOME}/.unison 
#             -v /etc/group:/etc/group:ro 
#             -v /etc/passwd:/etc/passwd:ro 
#             -u $(id -u ${USER})
#             -v <host-dir>:/mnthost codenvy/che-mount <ws-id|ws-name> 
#            
#  On Mac or Windows:
#  docker run --rm -it --cap-add SYS_ADMIN --device /dev/fuse
#             --name che-mount 
#             -v ~/.ssh:/root/.ssh
#             -v <host-dir>:/mnthost codenvy/che-mount <ws-id|ws-name> 
#
# RUN IN CONTAINER:
#  echo "secret" | $(echo "yes" | sshfs user@10.0.75.2:/projects /mntssh -p 32774)
#
# TO UNMOUNT IN CONTAINER
#  fusermount -u /mntssh
#
# INTERNAL SYNC SCRIPT
#   /bin/synch.sh <ip> <ws-port>
# 
# Will need to update sync agent with custom build binaries. Compile with https://github.com/ocaml/opam-dockerfiles.
#

FROM alpine:3.4

ENV UNISON_VERSION=2.40.102

RUN apk add --update build-base curl bash sshfs && \
    apk add ocaml --update-cache --repository http://dl-6.alpinelinux.org/alpine/edge/testing/ --allow-untrusted && \
    curl -L https://www.seas.upenn.edu/~bcpierce/unison/download/releases/unison-$UNISON_VERSION/unison-$UNISON_VERSION.tar.gz | tar xzv -C /tmp && \
    cd /tmp/unison-$UNISON_VERSION && \
    make && \
    cp /tmp/unison-$UNISON_VERSION/unison /usr/local/bin && \
    apk del ocaml curl build-base bash && \
    rm -rf /tmp /var/cache/apk/* && \
    mkdir /mntssh && chmod -R 777 /mntssh && \
    mkdir /mnthost && chmod -R 777 /mnthost

ENV DOCKER_BUCKET get.docker.com
ENV DOCKER_VERSION 1.6.0

RUN set -x \
    && apk add --no-cache \
    ca-certificates \
    curl \
    openssl \
    && curl -sL "https://${DOCKER_BUCKET}/builds/Linux/x86_64/docker-$DOCKER_VERSION" \
    > /usr/bin/docker; chmod +x /usr/bin/docker \
    && apk del curl ca-certificates openssl

COPY /entrypoint.sh /bin/entrypoint.sh

RUN chmod u+x /bin/entrypoint.sh

ENTRYPOINT ["/bin/entrypoint.sh"]
