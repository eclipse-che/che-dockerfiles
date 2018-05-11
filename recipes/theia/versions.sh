#!/bin/bash
# Copyright (c) 2018 Red Hat, Inc.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
#
# Contributors:
#   Red Hat, Inc. - initial API and implementation
set -e

THEIA_VERSION="0.3.7"
LATEST_VERSION="latest"

# modify  package json files according to provided THEIA_VERSION. Check if included packages are available before running sed
PACKAGES_FULL=$(cat /home/default/theia/package.json | jq -r '.dependencies | keys | .[]')
for i in ${PACKAGES_FULL[@]}; do
    PACKAGE=$(npm show ${i}@${THEIA_VERSION})
    if [ -z "${PACKAGE}" ]; then
      echo "${i} package with version ${THEIA_VERSION} not found. Using latest"
    else
      echo "Found ${i} package with version ${THEIA_VERSION}"
      sed -i "s#\"${i}\": \"latest\"#\"${i}\": \"${THEIA_VERSION}\"#g" /home/default/theia/package.json
    fi
done

# edit dev dependency version
sed -i "s#\"@theia/cli\": \"latest\"#\"@theia/cli\": \"${THEIA_VERSION}\"#g" /home/default/theia/package.json
