#!/bin/sh
# Copyright (c) 2012-2017 Red Hat, Inc
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html

set -e

# insert settings for mirrors/repository managers into settings.xml if supplied
configure_mirrors() {
  if [ -n "$MAVEN_MIRROR_URL" ]; then
    xml="    <mirror>\
      <id>mirror.default</id>\
      <url>$MAVEN_MIRROR_URL</url>\
      <mirrorOf>external:*</mirrorOf>\
    </mirror>"
    sed -i "s|<!-- ### configured mirrors ### -->|$xml|" "{$HOME}/.m2/settings.xml"
  fi
}

# check for the MAVEN_MIRROR_URL env variable, if its available then set maven mirrors in $HOME/.m2/settings.xml
configure_mirrors

while :; do sleep 1; done
