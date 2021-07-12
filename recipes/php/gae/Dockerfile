# Copyright (c) 2012-2018 Red Hat, Inc.
# This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v2.0
# which is available at http://www.eclipse.org/legal/epl-2.0.html
#
# SPDX-License-Identifier: EPL-2.0
#
# Contributors:
#   Red Hat, Inc. - initial API and implementation

FROM eclipse/php
ENV GAE /home/user/google_appengine
ENV GAE_VERSION="1.9.70"

RUN sudo apt-get update && \
    sudo apt-get install --no-install-recommends -y -q build-essential python2.7 python2.7-dev python-pip php-bcmath && \
    sudo pip install -U pip && \
    sudo pip install virtualenv
RUN cd /home/user/ && wget -q https://storage.googleapis.com/appengine-sdks/featured/google_appengine_${GAE_VERSION}.zip && \
    unzip -q google_appengine_${GAE_VERSION}.zip && \
    rm google_appengine_${GAE_VERSION}.zip && \
    for f in "/home/user/google_appengine"; do \
      sudo chgrp -R 0 ${f} && \
      sudo chmod -R g+rwX ${f}; \
    done
EXPOSE 8080 8000
