#!/bin/sh
# Copyright (c) 2019-2019 Red Hat, Inc
# This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v2.0
# which is available at http://www.eclipse.org/legal/epl-2.0.html
#
# SPDX-License-Identifier: EPL-2.0

set -ex

echo -e "${BLUE}Installing Quarkus.io dependencies..."
mkdir /tmp/install_quarkus_dependencies ; cd /tmp/install_quarkus_dependencies

git clone https://github.com/quarkusio/quarkus-quickstarts.git ; cd quarkus-quickstarts
# Make sure that this line closely matches the one in test.sh (which simulates what a Che end-user will do)
./mvnw -DskipTests -Ddocker.skip=true clean install dependency:go-offline dependency:resolve-plugins
# We skip tests just to speed up the build of this container, but to still make 'mvn test' work without downloads:
./mvnw org.apache.maven.plugins:maven-surefire-plugin:help

rm -Rf /tmp/install_quarkus_dependencies
echo -e "${BLUE}Quarkus.io dependencies installed ${NC}"
