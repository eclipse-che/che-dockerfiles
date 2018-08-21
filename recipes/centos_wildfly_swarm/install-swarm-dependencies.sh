#!/bin/sh
# Copyright (c) 2012-2017 Red Hat, Inc
# This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v2.0
# which is available at http://www.eclipse.org/legal/epl-2.0.html
#
# SPDX-License-Identifier: EPL-2.0

RED='\033[0;31m'
NC='\033[0m' # No Color
YELLOW='\033[0;33m'
BLUE='\033[0;34m'

cleanup() {
  rm -rf $TMP_DIR
}

if [ -z  $SWARM_VERSION ]; then
  echo -e "${RED}SWARM_VERSION must be defined! ${NC}"
  exit 1
fi

BOM_ALL_POM_URL="https://repo1.maven.org/maven2/org/wildfly/swarm/bom-all/${SWARM_VERSION}/bom-all-${SWARM_VERSION}.pom"
TMP_DIR="/tmp/swarm-${SWARM_VERSION}"
LOG_FILE="${TMP_DIR}/maven-swarm-${SWARM_VERSION}.log"
POM_FILE="${TMP_DIR}/pom-bom-all-${SWARM_VERSION}.xml"
SWARM_PLUGIN_SNIPPET="<build><directory>${TMP_DIR}\/target<\/directory><plugins><plugin><groupId>org.wildfly.swarm<\/groupId><artifactId>wildfly-swarm-plugin<\/artifactId><version>${SWARM_VERSION}<\/version><executions><execution><goals><goal>package<\/goal><\/goals><\/execution><\/executions><\/plugin><\/plugins>"

echo -e "${BLUE}================================== \n\n Installing WildFly Swarm ${SWARM_VERSION} dependencies...\n\n BOM_ALL_POM_URL: ${BOM_ALL_POM_URL}\n\n TMP_DIR: ${TMP_DIR} \n\n ================================== \n"
cleanup
mkdir $TMP_DIR

# Get the bom-all pom.xml
wget $BOM_ALL_POM_URL -O $POM_FILE -q

if [ ! -s $POM_FILE ]; then
  echo -e "${RED}Unable to obtain bom-all-${SWARM_VERSION}.pom from ${BOM_ALL_POM_URL} ${NC}"
  cleanup
  exit 1
fi

echo -e "${YELLOW} BOM ALL pom.xml downloaded to ${POM_FILE} ${NC}"

# Transform the bom-all pom.xml into a dummy Swarm app
# First remove <dependencyManagement> tags - all the fractions are used
sed -i -e '/dependencyManagement/d' $POM_FILE
# Replace <packaging>pom</packaging> with <packaging>war</packaging>
sed -i -e 's/<packaging>pom<\/packaging>/<packaging>war<\/packaging>/' $POM_FILE
# Add Swarm plugin - we need this to obtain WildFly modules
sed -i -e "s|<build>|$SWARM_PLUGIN_SNIPPET|" $POM_FILE

echo -e "${YELLOW} BOM ALL pom.xml transformed, resolving dependencies... ${NC}"
echo -e "${YELLOW} Log file: ${LOG_FILE} ${NC}"

# Resolve dependencies - Swarm plugin takes care of additional WildFly module dependencies
mvn clean package -f $POM_FILE > $LOG_FILE
if [ $? -eq 0 ]; then
  echo -e "${BLUE} WildFly Swarm ${SWARM_VERSION} dependencies installed ${NC}"
else
    echo -e "${RED}Unable to install WildFly Swarm ${SWARM_VERSION} dependencies ${NC}"
    cat $LOG_FILE
fi

cleanup
