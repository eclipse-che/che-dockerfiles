# Copyright (c) 2012-2018 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#
# Contributors:
#   Red Hat, Inc. - initial API and implementation

FROM eclipse/stack-base:debian

ENV GAE /home/user/google_appengine

RUN sudo apt-get update && \
    sudo apt-get install --no-install-recommends -y -q build-essential python2.7 python2.7-dev python-pip && \
    sudo pip install -U pip && \
    sudo pip install virtualenv
RUN wget -qO- "https://storage.googleapis.com/appengine-sdks/featured/google_appengine_1.9.40.zip" -O /tmp/gae-sdk.zip && \
    unzip -q /tmp/gae-sdk.zip -d /home/user && \
    rm /tmp/gae-sdk.zip

EXPOSE 8080 8000
