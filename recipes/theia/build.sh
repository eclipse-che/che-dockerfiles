#!/bin/sh
# Copyright (c) 2018 Red Hat, Inc.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
#
# Contributors:
#   Red Hat, Inc. - initial API and implementation
set -e

if [ -z ${GITHUB_TOKEN+x} ]; then
  echo "GITHUB_TOKEN is missing. Theia build may fail if rate limit is exceeded"
  echo "It is recommended to obtain GitHub token and export it before running this script."
  echo "Visit https://github.com/settings/tokens"
  echo "Example: export GITHUB_TOKEN=hfdjhtrye554s90snosif3454023ndik"
else
  echo "GitHub token found: ${GITHUB_TOKEN}"
fi


DEFAULT_THEIA_VERSION="0.3.7"
export THEIA_VERSION=${THEIA_VERSION:-${DEFAULT_THEIA_VERSION}}

export BUILD_ARG_GITHUB_TOKEN="--build-arg GITHUB_TOKEN=${GITHUB_TOKEN}"
export BUILD_ARG_THEIA_VERSION="--build-arg THEIA_VERSION=${THEIA_VERSION}"

echo "********************************************"
echo "Building Docker image eclipse/che-theia:${THEIA_VERSION}:"
echo "Theia version: ${THEIA_VERSION}"
echo "GITHUB_TOKEN=${GITHUB_TOKEN}"
echo "********************************************"
docker build -t eclipse/che-theia:${THEIA_VERSION} ${BUILD_ARG_GITHUB_TOKEN} ${BUILD_ARG_THEIA_VERSION} .
