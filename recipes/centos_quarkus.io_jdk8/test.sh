#!/bin/bash
# Copyright (c) 2019-2019 Red Hat, Inc
# This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v2.0
# which is available at http://www.eclipse.org/legal/epl-2.0.html
#
# SPDX-License-Identifier: EPL-2.0

set -ex

docker build -t che-stacks/centos-quarkus.io-jdk8-test .

echo "The following Maven build should be quick and not download any dependencies anymore..."
docker run --rm --name centos-quarkus.io-jdk8-test-run che-stacks/centos-quarkus.io-jdk8-test \
    bash -c "\
        git clone https://github.com/quarkusio/quarkus-quickstarts.git ; \
        cd quarkus-quickstarts; \
        ./mvnw -DskipTests -Ddocker.skip=true clean install"
# Make sure that this ^^^ closely matches what a Che end-user will do,
# and keep the Maven arguments here in line with install_quarkus_dependencies.sh.
# (NB: skipTests is special just to make this run fast; see install_quarkus_dependencies.sh)


# For (manual) testing of quarkus:dev, to make sure it doesn't download anything additional (it does not), use:
#
# docker run --rm --name centos-quarkus.io-jdk8-test-run che-stacks/centos-quarkus.io-jdk8-test \
#    bash -c "\
#        git clone https://github.com/quarkusio/quarkus-quickstarts.git ; \
#        cd quarkus-quickstarts/getting-started ; \
#        ./mvnw compile quarkus:dev"
