#!/bin/sh
DIR=$(cd "$(dirname "$0")"; pwd)
echo "Generating TypeScript DTO from $DIR directory"
cd $DIR
rm -rf target
docker run -it --rm -v "$HOME/.m2:/root/.m2" -v "$PWD":/usr/src/mymaven -w /usr/src/mymaven maven:3.3-jdk-8 /bin/bash -c "groupadd user && useradd -g user user && (chown --silent -R user.user /usr/src/app || true) && mvn -DskipTests=true -Dfindbugs.skip=true -Dskip-validate-sources install && (chown --silent -R user.user /usr/src/app || true)"
mkdir -p ../typescript/src/api/dto
cp target/dto-typescript.ts ../typescript/src/api/dto/che-dto.ts
