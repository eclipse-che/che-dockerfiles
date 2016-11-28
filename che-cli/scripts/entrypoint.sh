#!/bin/bash
# Copyright (c) 2016 Codenvy, S.A.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
#
# Contributors:
#   Tyler Jewell - Initial Implementation
#

init_usage() {
  USAGE="
Usage: docker run -it --rm
                  -v /var/run/docker.sock:/var/run/docker.sock
                  -v <LOCAL_DATA_PATH>:${CHE_CONTAINER_ROOT}
                  ${CHE_IMAGE_NAME} [COMMAND]

    help                                 This message
    version                              Installed version and upgrade paths
    init                                 Initializes a directory with a ${CHE_FORMAL_PRODUCT_NAME} install
         [--no-force                         Default - uses cached local Docker images
          --pull                             Checks for newer images from DockerHub
          --force                            Removes all images and re-pulls all images from DockerHub
          --offline                          Uses images saved to disk from the offline command
          --accept-license                   Auto accepts the ${CHE_FORMAL_PRODUCT_NAME} license during installation
          --reinit]                          Reinstalls using existing $CHE_MINI_PRODUCT_NAME.env configuration
    start [--pull | --force | --offline] Starts ${CHE_FORMAL_PRODUCT_NAME} services
    stop                                 Stops ${CHE_FORMAL_PRODUCT_NAME} services
    restart [--pull | --force]           Restart ${CHE_FORMAL_PRODUCT_NAME} services
    destroy                              Stops services, and deletes ${CHE_FORMAL_PRODUCT_NAME} instance data
            [--quiet                         Does not ask for confirmation before destroying instance data
             --cli]                          If :/cli is mounted, will destroy the cli.log
    rmi [--quiet]                        Removes the Docker images for <version>, forcing a repull
    config                               Generates a ${CHE_FORMAL_PRODUCT_NAME} config from vars; run on any start / restart
    upgrade                              Upgrades ${CHE_FORMAL_PRODUCT_NAME} from one version to another with migrations and backups
    download [--pull|--force|--offline]  Pulls Docker images for the current ${CHE_FORMAL_PRODUCT_NAME} version
    backup [--quiet | --skip-data]       Backups $${CHE_FORMAL_PRODUCT_NAME} configuration and data to ${CHE_CONTAINER_ROOT}/backup volume mount
    restore [--quiet]                    Restores ${CHE_FORMAL_PRODUCT_NAME} configuration and data from ${CHE_CONTAINER_ROOT}/backup mount
    offline                              Saves ${CHE_FORMAL_PRODUCT_NAME} Docker images into TAR files for offline install
    info                                 Displays info about ${CHE_FORMAL_PRODUCT_NAME} and the CLI
         [ --all                             Run all debugging tests
           --debug                           Displays system information
           --network]                        Test connectivity between ${CHE_FORMAL_PRODUCT_NAME} sub-systems
    ssh <wksp-name> [machine-name]       SSH to a workspace if SSH agent enabled
    mount <wksp-name>                    Synchronize workspace with current working directory
    action <action-name> [--help]        Start action on ${CHE_FORMAL_PRODUCT_NAME} instance
    test <test-name> [--help]            Start test on ${CHE_FORMAL_PRODUCT_NAME} instance

Variables:
    CHE_HOST                             IP address or hostname where ${CHE_FORMAL_PRODUCT_NAME} will serve its users
    CLI_DEBUG                            Default=false. Prints stack trace during execution
    CLI_INFO                             Default=true. Prints out INFO messages to standard out
    CLI_WARN                             Default=true. Prints WARN messages to standard out
    CLI_LOG                              Default=true. Prints messages to cli.log file
"
}

check_docker() {
  if ! has_docker; then
    error "Docker not found. Get it at https://docs.docker.com/engine/installation/."
    return 1;
  fi

  # If DOCKER_HOST is not set, then it should bind mounted
  if [ -z "${DOCKER_HOST+x}" ]; then
    if ! docker ps > /dev/null 2>&1; then
      info "Welcome to ${CHE_FORMAL_PRODUCT_NAME}!"
      info ""
      info "$CHE_FORMAL_PRODUCT_NAME commands require additional parameters:"
      info "  Mounting 'docker.sock', which let's us access Docker"
      info ""
      info "Syntax:"
      info "  docker run -it --rm ${BOLD} -v /var/run/docker.sock:/var/run/docker.sock${NC}"
      info "                  $CHE_MINI_PRODUCT_NAME/cli $*"
      return 2;
    fi
  fi

  DOCKER_VERSION=($(docker version |  grep  "Version:" | sed 's/Version://'))

  MAJOR_VERSION_ID=$(echo ${DOCKER_VERSION[0]:0:1})
  MINOR_VERSION_ID=$(echo ${DOCKER_VERSION[0]:2:2})

  # Docker needs to be greater than or equal to 1.11
  if [[ ${MAJOR_VERSION_ID} -lt 1 ]] ||
     [[ ${MINOR_VERSION_ID} -lt 11 ]]; then
       error "Error - Docker engine 1.11+ required."
       return 2;
  fi

  DEFAULT_CHE_VERSION=$(cat "/version/latest.ver")
  CHE_IMAGE_NAME=$(docker inspect --format='{{.Config.Image}}' $(get_this_container_id))
  CHE_IMAGE_VERSION=$(echo "${CHE_IMAGE_NAME}" | cut -d : -f2 -s)

  if [[ "${CHE_IMAGE_VERSION}" = "" ]] ||
     [[ "${CHE_IMAGE_VERSION}" = "latest" ]]; then
     warning "You are using CLI image version 'latest' which is set to '${DEFAULT_CHE_VERSION}'."
    CHE_IMAGE_VERSION=${DEFAULT_CHE_VERSION}
  fi

  CHE_VERSION=${CHE_IMAGE_VERSION}
}
  
check_mounts() {

  # Verify that we can write to the host file system from the container
  check_host_volume_mount

  DATA_MOUNT=$(get_container_folder ":${CHE_CONTAINER_ROOT}")
  INSTANCE_MOUNT=$(get_container_folder ":${CHE_CONTAINER_ROOT}/instance")
  BACKUP_MOUNT=$(get_container_folder ":${CHE_CONTAINER_ROOT}/backup")
  REPO_MOUNT=$(get_container_folder ":/repo")
  CLI_MOUNT=$(get_container_folder ":/cli")
  SYNC_MOUNT=$(get_container_folder ":/sync")
  UNISON_PROFILE_MOUNT=$(get_container_folder ":/unison")

  if [[ "${DATA_MOUNT}" = "not set" ]]; then
    info "Welcome to $CHE_FORMAL_PRODUCT_NAME!"
    info ""
    info "We need some information before we can start ${CHE_FORMAL_PRODUCT_NAME}."
    info ""
    info "$CHE_FORMAL_PRODUCT_NAME commands require additional parameters:"
    info "  1: Mounting 'docker.sock', which let's us access Docker"
    info "  2: A local path where ${CHE_FORMAL_PRODUCT_NAME} will save user data"
    info ""
    info "Simplest syntax:"
    info "  docker run -it --rm -v /var/run/docker.sock:/var/run/docker.sock"
    info "                      -v <YOUR_LOCAL_PATH>:${CHE_CONTAINER_ROOT}"
    info "                         ${CHE_IMAGE_NAME} $*"
    info ""
    info ""
    info "Or run with overrides for instance and/or backup:"
    info "  docker run -it --rm -v /var/run/docker.sock:/var/run/docker.sock"
    info "                      -v <YOUR_LOCAL_PATH>:${CHE_CONTAINER_ROOT}"
    info "                      -v <YOUR_INSTANCE_PATH>:${CHE_CONTAINER_ROOT}/instance"
    info "                      -v <YOUR_BACKUP_PATH>:${CHE_CONTAINER_ROOT}/backup"
    info "                         ${CHE_IMAGE_NAME} $*"
    return 2;
  fi

  DEFAULT_CHE_CONFIG="${DATA_MOUNT}"
  DEFAULT_CHE_INSTANCE="${DATA_MOUNT}"/instance
  DEFAULT_CHE_BACKUP="${DATA_MOUNT}"/backup

  if [[ "${INSTANCE_MOUNT}" != "not set" ]]; then
    DEFAULT_CHE_INSTANCE="${INSTANCE_MOUNT}"
  fi

  if [[ "${BACKUP_MOUNT}" != "not set" ]]; then
    DEFAULT_CHE_BACKUP="${BACKUP_MOUNT}"
  fi

  #   Set offline to CONFIG_MOUNT
  CHE_HOST_CONFIG=${CHE_CONFIG:-${DEFAULT_CHE_CONFIG}}
  CHE_CONTAINER_CONFIG="${CHE_CONTAINER_ROOT}"

  CHE_HOST_INSTANCE=${CHE_INSTANCE:-${DEFAULT_CHE_INSTANCE}}
  CHE_CONTAINER_INSTANCE="${CHE_CONTAINER_ROOT}/instance"

  CHE_HOST_BACKUP=${CHE_BACKUP:-${DEFAULT_CHE_BACKUP}}
  CHE_CONTAINER_BACKUP="${CHE_CONTAINER_ROOT}/backup"

  ### DEV MODE VARIABLES
  CHE_DEVELOPMENT_MODE="off"
  if [[ "${REPO_MOUNT}" != "not set" ]]; then
    CHE_DEVELOPMENT_MODE="on"
    CHE_HOST_DEVELOPMENT_REPO="${REPO_MOUNT}"
    CHE_CONTAINER_DEVELOPMENT_REPO="/repo"

    DEFAULT_CHE_ASSEMBLY="assembly/assembly-main/target/eclipse-che*/eclipse-che-*"
    CHE_ASSEMBLY="${CHE_HOST_INSTANCE}/dev"

    if [[ ! -d "${CHE_CONTAINER_DEVELOPMENT_REPO}"  ]] || [[ ! -d "${CHE_CONTAINER_DEVELOPMENT_REPO}/assembly" ]]; then
      info "Welcome to $CHE_FORMAL_PRODUCT_NAME!"
      info ""
      info "You volume mounted ':/repo', but we did not detect a valid ${CHE_FORMAL_PRODUCT_NAME} source repo."
      info ""
      info "Volume mounting ':/repo' activate dev mode, using assembly and CLI files from $CHE_FORMAL_PRODUCT_NAME repo."
      info ""
      info "Please check the path you mounted to verify that is a valid $CHE_FORMAL_PRODUCT_NAME git repository."
      info ""
      info "Simplest syntax::"
      info "  docker run -it --rm -v /var/run/docker.sock:/var/run/docker.sock"
      info "                      -v <YOUR_LOCAL_PATH>:${CHE_CONTAINER_ROOT}"
      info "                      -v <YOUR_${CHE_PRODUCT_NAME}_REPO>:/repo"
      info "                         ${CHE_IMAGE_NAME} $*"
      info ""
      info ""
      info "Or run with overrides for instance, and backup (all required):"
      info "  docker run -it --rm -v /var/run/docker.sock:/var/run/docker.sock"
      info "                      -v <YOUR_LOCAL_PATH>:${CHE_CONTAINER_ROOT}"
      info "                      -v <YOUR_INSTANCE_PATH>:${CHE_CONTAINER_ROOT}/instance"
      info "                      -v <YOUR_BACKUP_PATH>:${CHE_CONTAINER_ROOT}/backup"
      info "                      -v <YOUR_${CHE_PRODUCT_NAME}_REPO>:/repo"
      info "                         ${CHE_IMAGE_NAME} $*"
      return 2
    fi
    if [[ ! -d $(echo ${CHE_CONTAINER_DEVELOPMENT_REPO}/${DEFAULT_CHE_ASSEMBLY}) ]]; then
      info "Welcome to $CHE_FORMAL_PRODUCT_NAME!"
      info ""
      info "You volume mounted a valid $CHE_FORMAL_PRODUCT_NAME repo to ':/repo', but we could not find a Tomcat assembly."
      info "Have you built /assembly/assembly-main with 'mvn clean install'?"
      return 2
    fi
  fi
}

source /scripts/base/startup.sh
start "$@"
