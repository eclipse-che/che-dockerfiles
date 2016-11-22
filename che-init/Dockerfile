# Copyright (c) 2012-2016 Codenvy, S.A.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
#
# Contributors:
#   Tyler Jewell - Initial Implementation
#

# Initializes an empty directory with the templates needed to configure and run Che.
#
# Build:
#   docker build -t eclipse/che-init:<version> .
#
# Use:
#    docker run -v $(pwd):/copy eclipse/che-init:<version>

FROM alpine:latest
RUN mkdir -p /files \
    && mkdir -p /files/modules \
    && mkdir -p /files/manifests

COPY manifests /files/manifests
COPY modules /files/modules
COPY README.md /files
COPY DOCS.md /files
COPY entrypoint.sh /
RUN chmod +x entrypoint.sh

ENV ENVFILE=che.env

ENTRYPOINT ["/entrypoint.sh"]
