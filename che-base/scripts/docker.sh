#!/bin/sh
# Copyright (c) 2016 Codenvy, S.A.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html

# Contains docker scripts

has_docker() {
  hash docker 2>/dev/null && return 0 || return 1
}

has_compose() {
  hash docker-compose 2>/dev/null && return 0 || return 1
}

get_container_bind_folder() {
  THIS_CONTAINER_ID=$(get_this_container_id)
  FOLDER=$(get_container_host_bind_folder ":${CHE_CONTAINER_ROOT}" $THIS_CONTAINER_ID)
  echo "${FOLDER:=not set}"
}

get_container_config_folder() {
  THIS_CONTAINER_ID=$(get_this_container_id)
  FOLDER=$(get_container_host_bind_folder ":${CHE_CONTAINER_ROOT}/config" $THIS_CONTAINER_ID)
  echo "${FOLDER:=not set}"
}

get_container_instance_folder() {
  THIS_CONTAINER_ID=$(get_this_container_id)
  FOLDER=$(get_container_host_bind_folder ":${CHE_CONTAINER_ROOT}/instance" $THIS_CONTAINER_ID)
  echo "${FOLDER:=not set}"
}

get_container_backup_folder() {
  THIS_CONTAINER_ID=$(get_this_container_id)
  FOLDER=$(get_container_host_bind_folder ":${CHE_CONTAINER_ROOT}/backup" $THIS_CONTAINER_ID)
  echo "${FOLDER:=not set}"
}

get_container_repo_folder() {
  THIS_CONTAINER_ID=$(get_this_container_id)
  FOLDER=$(get_container_host_bind_folder ":/repo" $THIS_CONTAINER_ID)
  echo "${FOLDER:=not set}"
}

get_container_cli_folder() {
  THIS_CONTAINER_ID=$(get_this_container_id)
  FOLDER=$(get_container_host_bind_folder ":/cli" $THIS_CONTAINER_ID)
  echo "${FOLDER:=not set}"
}

get_container_sync_folder() {
  THIS_CONTAINER_ID=$(get_this_container_id)
  FOLDER=$(get_container_host_bind_folder ":/sync" $THIS_CONTAINER_ID)
  echo "${FOLDER:=not set}"
}

get_container_unison_folder() {
  THIS_CONTAINER_ID=$(get_this_container_id)
  FOLDER=$(get_container_host_bind_folder ":/unison" $THIS_CONTAINER_ID)
  echo "${FOLDER:=not set}"
}

get_this_container_id() {
  hostname
}

get_container_host_bind_folder() {
  # BINDS in the format of var/run/docker.sock:/var/run/docker.sock <path>:${CHE_CONTAINER_ROOT}
  BINDS=$(docker inspect --format="{{.HostConfig.Binds}}" "${2}" | cut -d '[' -f 2 | cut -d ']' -f 1)

  # Remove /var/run/docker.sock:/var/run/docker.sock
  VALUE=${BINDS/\/var\/run\/docker\.sock\:\/var\/run\/docker\.sock/}

  # Remove leading and trailing spaces
  VALUE2=$(echo "${VALUE}" | xargs)

  MOUNT=""
  IFS=$' '
  for SINGLE_BIND in $VALUE2; do
    case $SINGLE_BIND in
      *$1)
        MOUNT="${MOUNT} ${SINGLE_BIND}"
        echo "${MOUNT}" | cut -f1 -d":" | xargs
      ;;
      *)
        # Super ugly - since we parse by space, if the next parameter is not a colon, then
        # we know that next parameter is second part of a directory with a space in it.
        if [[ ${SINGLE_BIND} != *":"* ]]; then
          MOUNT="${MOUNT} ${SINGLE_BIND}"
        else
          MOUNT=""
        fi
      ;;
    esac
  done
}

docker_run() {
  debug $FUNCNAME
  # Setup options for connecting to docker host
  if [ -z "${DOCKER_HOST+x}" ]; then
      DOCKER_HOST="/var/run/docker.sock"
  fi

  if [ -S "$DOCKER_HOST" ]; then
    docker run --rm -v $DOCKER_HOST:$DOCKER_HOST \
                    -v $HOME:$HOME \
                    -w "$(pwd)" "$@"
  else
    docker run --rm -e DOCKER_HOST -e DOCKER_TLS_VERIFY -e DOCKER_CERT_PATH \
                    -v $HOME:$HOME \
                    -w "$(pwd)" "$@"
  fi
}

docker_compose() {
  debug $FUNCNAME

  if has_compose; then
    docker-compose "$@"
  else
    docker_run -v "${CHE_HOST_INSTANCE}":"${CHE_CONTAINER_INSTANCE}" \
                  docker/compose:1.8.1 "$@"
  fi
}
