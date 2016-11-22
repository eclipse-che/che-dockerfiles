#!/bin/sh
# Copyright (c) 2012-2016 Codenvy, S.A.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
#
# Contributors:
#   Tyler Jewell - Initial Implementation
#

# Make sure service is running
cp -rf /files/manifests /copy
cp -rf /files/modules /copy
cp -rf /files/README.md /copy
cp -rf /files/DOCS.md /copy
# do not copy che.env if exist
if [ ! -f  /copy/${ENVFILE} ]; then
    cp /files/manifests/${ENVFILE} /copy
fi
