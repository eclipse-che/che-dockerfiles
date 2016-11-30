#!/usr/bin/env bash
# Copyright (c) 2016 Codenvy, S.A.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html

IMAGE_NAME="eclipse/che-lib-typescript"
. $(cd "$(dirname "$0")"; pwd)/../build.include

DIR=$(cd "$(dirname "$0")"; pwd)

generate_dto() {
  echo "Checking DTO"

  # if file already exists and in snapshot mode
  POM_VERSION=$(cat ${DIR}/dto-pom.xml | grep "^        <version>.*</version>$" | awk -F'[><]' '{print $3}')
  if [ -e "${DIR}/src/api/dto/che-dto.ts" ]; then
    # DTO file exists, Do we have snapshot ?
    if [[ ${POM_VERSION} != *"SNAPSHOT" ]]
    then
      if [ ${DIR}/src/api/dto/che-dto.ts -nt ${DIR}/dto-pom.xml ]; then
        echo "Using tagged version and dto file is up-to-date. Not generating it."
        return
      else
        echo "Using tagged version but DTO file is older than dto-pom.xml file. Need to generate again."
      fi
    else
      echo "Snapshot version is used in pom.xml. Generating again pom.xml";
    fi
  fi
  
  docker ps -a | awk '{ print $1,$2 }' | grep che-typescript-build | awk '{print $1 }' | xargs -I {} docker rm -f {}
  docker run -d --name che-typescript-build -v "$HOME/.m2:/root/.m2" -w /usr/src/mymaven maven:3.3-jdk-8 tail -f /dev/null
  docker cp $DIR/dto-pom.xml che-typescript-build:/usr/src/mymaven/pom.xml  
  cd $DIR && docker exec -ti che-typescript-build /bin/bash -c "cd /usr/src/mymaven && mvn -q -DskipTests=true -Dfindbugs.skip=true -Dskip-validate-sources clean install && ls target/"
  docker cp che-typescript-build:/usr/src/mymaven/target/dto-typescript.ts /tmp/dto-typescript.ts
  DTO_CONTENT=$(cat /dto-typescript.ts)
  docker rm -f che-typescript-build 2> /dev/null

  # Check if maven command has worked or not
  if [ $? -eq 0 ]; then
    # Create directory if it doesn't exist
    if [ ! -d "${DIR}/src/api/dto" ]; then
      mkdir ${DIR}/src/api/dto
    fi
    
    if [ ! -s /tmp/dto-typescript.ts ]; then
        rm -r ${DIR}/src/api/dto
        echo "Failure when generating DTO."
        exit 1
    fi
    cp /tmp/dto-typescript.ts ${DIR}/src/api/dto/che-dto.ts
    echo 'DTO has been generated'
  else
    echo "Failure when generating DTO. Error was ${DTO_CONTENT}"
    exit 1
  fi
}


native_build() {
  ./node_modules/typescript/bin/tsc --project .
}

init
generate_dto

DIR=$(cd "$(dirname "$0")"; pwd)
echo "Building Docker Image ${IMAGE_NAME} from $DIR directory with tag $TAG"
cd $DIR && docker build -t ${IMAGE_NAME}:${TAG} .
if [ $? -eq 0 ]; then
  echo "${GREEN}Script run successfully: ${BLUE}${IMAGE_NAME}:${TAG}${NC}"
else
  echo "${RED}Failure when building docker image ${IMAGE_NAME}:${TAG}${NC}"
  exit 1
fi
