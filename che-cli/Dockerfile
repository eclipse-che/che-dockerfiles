# Copyright (c) 2016 Codenvy, S.A.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
#
# build:
#   docker build -t eclipse/che-cli .
#
# use:
#    docker run -v $(pwd):/che eclipse/che-cli [command]
FROM alpine:3.4
RUN mkdir -p /che \
    && mkdir -p /version \
    && mkdir -p /cli \
    && apk add --no-cache ca-certificates curl openssl jq \
    && apk add --update bash \
    && rm -rf /var/cache/apk/*

ENV DOCKER_BUCKET get.docker.com
ENV DOCKER_VERSION 1.11.2
ENV DOCKER_SHA256 8c2e0c35e3cda11706f54b2d46c2521a6e9026a7b13c7d4b8ae1f3a706fc55e1

RUN set -x \
	&& curl -fSL "https://${DOCKER_BUCKET}/builds/Linux/x86_64/docker-${DOCKER_VERSION}.tgz" -o docker.tgz \
	&& echo "${DOCKER_SHA256} *docker.tgz" | sha256sum -c - \
	&& tar -xzvf docker.tgz \
	&& mv docker/* /usr/local/bin/ \
	&& rmdir docker \
	&& rm docker.tgz \
	&& docker -v

COPY che.sh /scripts/
COPY cli.sh /scripts/
COPY cmd_*.sh /scripts/
COPY version /version/

RUN chmod +x /scripts/che.sh

ENTRYPOINT ["/scripts/che.sh"]



