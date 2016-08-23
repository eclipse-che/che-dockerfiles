#!/bin/sh
# Copyright (c) 2012-2016 Codenvy, S.A., Red Hat, Inc
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
if [ "latest" = "$1" ]
then
  TAG="latest"
else
  TAG="nightly"
fi

docker build -t codenvy/che-launcher:$TAG .