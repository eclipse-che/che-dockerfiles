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

cli_init() {

  # Constants
  CHE_MANIFEST_DIR="/version"
  CHE_CONTAINER_OFFLINE_FOLDER="/${CHE_MINI_PRODUCT_NAME}/backup"
  CHE_VERSION_FILE="${CHE_MINI_PRODUCT_NAME}.ver.do_not_modify"
  CHE_ENVIRONMENT_FILE="${CHE_MINI_PRODUCT_NAME}.env"
  CHE_COMPOSE_FILE="docker-compose-container.yml"
  CHE_SERVER_CONTAINER_NAME="che"
  CHE_CONFIG_BACKUP_FILE_NAME="${CHE_MINI_PRODUCT_NAME}_config_backup.tar"
  CHE_INSTANCE_BACKUP_FILE_NAME="${CHE_MINI_PRODUCT_NAME}_instance_backup.tar"
  DOCKER_CONTAINER_NAME_PREFIX="${CHE_MINI_PRODUCT_NAME}_"

  grab_offline_images "$@"
  grab_initial_images

  DEFAULT_CHE_CLI_ACTION="help"
  CHE_CLI_ACTION=${CHE_CLI_ACTION:-${DEFAULT_CHE_CLI_ACTION}}
  
  CHE_LICENSE=false

  GLOBAL_HOST_IP=${GLOBAL_HOST_IP:=$(docker_run --net host eclipse/che-ip:nightly)}
  DEFAULT_CHE_HOST=$GLOBAL_HOST_IP
  CHE_HOST=${CHE_HOST:-${DEFAULT_CHE_HOST}}
  DEFAULT_CHE_PORT=8080
  CHE_PORT=${CHE_PORT:-${DEFAULT_CHE_PORT}}

  if [[ "${CHE_HOST}" = "" ]]; then
    info "Welcome to ${CHE_PRODUCT_NAME}!"
    info ""
    info "We did not auto-detect a valid HOST or IP address."
    info "Pass CHE_HOST with your hostname or IP address."
    info ""
    info "Rerun the CLI:"
    info "  docker run -it --rm -v /var/run/docker.sock:/var/run/docker.sock"
    info "                      -v <local-path>:/codenvy"
    info "                      -e CHE_HOST=<your-ip-or-host>"
    info "                         eclipse/che-cli:${CHE_IMAGE_VERSION} $@"
    return 2;
  fi

  REFERENCE_HOST_ENVIRONMENT_FILE="${CHE_HOST_CONFIG}/${CHE_ENVIRONMENT_FILE}"
  REFERENCE_HOST_COMPOSE_FILE="${CHE_HOST_INSTANCE}/${CHE_COMPOSE_FILE}"
  REFERENCE_CONTAINER_ENVIRONMENT_FILE="${CHE_CONTAINER_CONFIG}/${CHE_ENVIRONMENT_FILE}"
  REFERENCE_CONTAINER_COMPOSE_FILE="${CHE_CONTAINER_INSTANCE}/${CHE_COMPOSE_FILE}"

  CHE_HOST_CONFIG_MANIFESTS_FOLDER="$CHE_HOST_CONFIG/manifests"
  CHE_CONTAINER_CONFIG_MANIFESTS_FOLDER="$CHE_CONTAINER_CONFIG/manifests"

  CHE_HOST_CONFIG_MODULES_FOLDER="$CHE_HOST_CONFIG/modules"
  CHE_CONTAINER_CONFIG_MODULES_FOLDER="$CHE_CONTAINER_CONFIG/modules"

  # TODO: Change this to use the current folder or perhaps ~?
  if is_boot2docker && has_docker_for_windows_client; then
    if [[ "${CHE_HOST_INSTANCE,,}" != *"${USERPROFILE,,}"* ]]; then
      CHE_HOST_INSTANCE=$(get_mount_path "${USERPROFILE}/.${CHE_MINI_PRODUCT_NAME}/")
      warning "Boot2docker for Windows - CHE_INSTANCE set to $CHE_HOST_INSTANCE"
    fi
    if [[ "${CHE_HOST_CONFIG,,}" != *"${USERPROFILE,,}"* ]]; then
      CHE_HOST_CONFIG=$(get_mount_path "${USERPROFILE}/.${CHE_MINI_PRODUCT_NAME}/")
      warning "Boot2docker for Windows - CHE_CONFIG set to $CHE_HOST_CONFIG"
    fi
  fi

  # Do not perform a version compatibility check if running upgrade command.
  # The upgrade command has its own internal checks for version compatibility.
  if [ $1 != "upgrade" ]; then 
    verify_version_compatibility
  else
    verify_version_upgrade_compatibility
  fi
}

grab_offline_images(){
  # If you are using codenvy in offline mode, images must be loaded here
  # This is the point where we know that docker is working, but before we run any utilities
  # that require docker.
  if [[ "$@" == *"--offline"* ]]; then
    info "init" "Importing ${CHE_MINI_PRODUCT_NAME} Docker images from tars..."

    if [ ! -d ${CHE_CONTAINER_OFFLINE_FOLDER} ]; then
      info "init" "You requested offline image loading, but '${CHE_CONTAINER_OFFLINE_FOLDER}' folder not found"
      return 2;
    fi

    IFS=$'\n'
    for file in "${CHE_CONTAINER_OFFLINE_FOLDER}"/*.tar
    do
      if ! $(docker load < "${CHE_CONTAINER_OFFLINE_FOLDER}"/"${file##*/}" > /dev/null); then
        error "Failed to restore ${CHE_MINI_PRODUCT_NAME} Docker images"
        return 2;
      fi
      info "init" "Loading ${file##*/}..."
    done
  fi
}

grab_initial_images() {
  # Prep script by getting default image
  if [ "$(docker images -q alpine:3.4 2> /dev/null)" = "" ]; then
    info "cli" "Pulling image alpine:3.4"
    log "docker pull alpine:3.4 >> \"${LOGS}\" 2>&1"
    TEST=""
    docker pull alpine:3.4 >> "${LOGS}" 2>&1 || TEST=$?
    if [ "$TEST" = "1" ]; then
      error "Image alpine:3.4 unavailable. Not on dockerhub or built locally."
      return 2;
    fi
  fi

  if [ "$(docker images -q appropriate/curl 2> /dev/null)" = "" ]; then
    info "cli" "Pulling image appropriate/curl:latest"
    log "docker pull appropriate/curl:latest >> \"${LOGS}\" 2>&1"
    TEST=""
    docker pull appropriate/curl >> "${LOGS}" 2>&1 || TEST=$?
    if [ "$TEST" = "1" ]; then
      error "Image appropriate/curl:latest unavailable. Not on dockerhub or built locally."
      return 2;
    fi
  fi

  if [ "$(docker images -q eclipse/che-ip:nightly 2> /dev/null)" = "" ]; then
    info "cli" "Pulling image eclipse/che-ip:nightly"
    log "docker pull eclipse/che-ip:nightly >> \"${LOGS}\" 2>&1"
    TEST=""
    docker pull eclipse/che-ip:nightly >> "${LOGS}" 2>&1 || TEST=$?
    if [ "$TEST" = "1" ]; then
      error "Image eclipse/che-ip:nightly unavailable. Not on dockerhub or built locally."
      return 2;
    fi
  fi
}

cli_parse () {
  debug $FUNCNAME
  COMMAND="cmd_$1"
  COMMAND_CONTAINER_FILE="${SCRIPTS_CONTAINER_SOURCE_DIR}"/$COMMAND.sh

  if [ ! -f "${COMMAND_CONTAINER_FILE}" ]; then
    error "You passed an unknown command line option."
    return 2;
  fi

  # Need to load all files in advance so commands can invoke other commands.
  for COMMAND_FILE in "${SCRIPTS_CONTAINER_SOURCE_DIR}"/cmd_*.sh
  do
    source "${COMMAND_FILE}"
  done

  shift
  eval $COMMAND "$@"
}

get_docker_install_type() {
  debug $FUNCNAME
  if is_boot2docker; then
    echo "boot2docker"
  elif is_docker_for_windows; then
    echo "docker4windows"
  elif is_docker_for_mac; then
    echo "docker4mac"
  else
    echo "native"
  fi
}

has_docker_for_windows_client(){
  debug $FUNCNAME
  if [[ "${GLOBAL_HOST_IP}" = "10.0.75.2" ]]; then
    return 0
  else
    return 1
  fi
}

is_boot2docker() {
  debug $FUNCNAME
  if uname -r | grep -q 'boot2docker'; then
    return 0
  else
    return 1
  fi
}

is_docker_for_windows() {
  debug $FUNCNAME
  if uname -r | grep -q 'moby' && has_docker_for_windows_client; then
    return 0
  else
    return 1
  fi
}

is_docker_for_mac() {
  debug $FUNCNAME
  if uname -r | grep -q 'moby' && ! has_docker_for_windows_client; then
    return 0
  else
    return 1
  fi
}

is_native() {
  debug $FUNCNAME
  if [ $(get_docker_install_type) = "native" ]; then
    return 0
  else
    return 1
  fi
}


has_env_variables() {
  debug $FUNCNAME
  PROPERTIES=$(env | grep CHE_)

  if [ "$PROPERTIES" = "" ]; then
    return 1
  else
    return 0
  fi
}

update_image_if_not_found() {
  debug $FUNCNAME

  text "${GREEN}INFO:${NC} (${CHE_MINI_PRODUCT_NAME} download): Checking for image '$1'..."
  CURRENT_IMAGE=$(docker images -q "$1")
  if [ "${CURRENT_IMAGE}" == "" ]; then
    text "not found\n"
    update_image $1
  else
    text "found\n"
  fi
}

update_image() {
  debug $FUNCNAME

  if [ "${1}" == "--force" ]; then
    shift
    info "download" "Removing image $1"
    log "docker rmi -f $1 >> \"${LOGS}\""
    docker rmi -f $1 >> "${LOGS}" 2>&1 || true
  fi

  if [ "${1}" == "--pull" ]; then
    shift
  fi

  info "download" "Pulling image $1"
  text "\n"
  log "docker pull $1 >> \"${LOGS}\" 2>&1"
  TEST=""
  docker pull $1 || TEST=$?
  if [ "$TEST" = "1" ]; then
    error "Image $1 unavailable. Not on dockerhub or built locally."
    return 2;
  fi
  text "\n"
}

port_open(){
  debug $FUNCNAME

  docker run -d -p $1:$1 --name fake alpine:3.4 httpd -f -p $1 -h /etc/ > /dev/null 2>&1
  NETSTAT_EXIT=$?
  docker rm -f fake > /dev/null 2>&1

  if [ $NETSTAT_EXIT = 125 ]; then
    return 1
  else
    return 0
  fi
}

container_exist_by_name(){
  docker inspect ${1} > /dev/null 2>&1
  if [ "$?" == "0" ]; then
    return 0
  else
    return 1
  fi
}

get_server_container_id() {
  log "docker inspect -f '{{.Id}}' ${1}"
  docker inspect -f '{{.Id}}' ${1}
}

wait_until_container_is_running() {
  CONTAINER_START_TIMEOUT=${1}

  ELAPSED=0
  until container_is_running ${2} || [ ${ELAPSED} -eq "${CONTAINER_START_TIMEOUT}" ]; do
    log "sleep 1"
    sleep 1
    ELAPSED=$((ELAPSED+1))
  done
}

container_is_running() {
  if [ "$(docker ps -qa -f "status=running" -f "id=${1}" | wc -l)" -eq 0 ]; then
    return 1
  else
    return 0
  fi
}

wait_until_server_is_booted () {
  SERVER_BOOT_TIMEOUT=${1}

  ELAPSED=0
  until server_is_booted ${2} || [ ${ELAPSED} -eq "${SERVER_BOOT_TIMEOUT}" ]; do
    log "sleep 2"
    sleep 2
    ELAPSED=$((ELAPSED+1))
  done
}

server_is_booted() {
  HTTP_STATUS_CODE=$(curl -I -k $CHE_HOST:$CHE_PORT/api/ \
                     -s -o "${LOGS}" --write-out "%{http_code}")
  if [[ "${HTTP_STATUS_CODE}" = "200" ]] || [[ "${HTTP_STATUS_CODE}" = "302" ]]; then
    return 0
  else
    return 1
  fi
}

check_if_booted() {
  CURRENT_CHE_SERVER_CONTAINER_ID=$(get_server_container_id $CHE_SERVER_CONTAINER_NAME)
  wait_until_container_is_running 20 ${CURRENT_CHE_SERVER_CONTAINER_ID}
  if ! container_is_running ${CURRENT_CHE_SERVER_CONTAINER_ID}; then
    error "(${CHE_MINI_PRODUCT_NAME} start): Timeout waiting for ${CHE_MINI_PRODUCT_NAME} container to start."
    return 2
  fi

  info "start" "Server logs at \"docker logs -f ${CHE_SERVER_CONTAINER_NAME}\""
  info "start" "Server booting..."
  wait_until_server_is_booted 60 ${CURRENT_CHE_SERVER_CONTAINER_ID}

  if server_is_booted ${CURRENT_CHE_SERVER_CONTAINER_ID}; then
    info "start" "Booted and reachable"
    info "start" "Ver: $(get_installed_version)"
    if ! is_docker_for_mac; then
      info "start" "Use: http://${CHE_HOST}:${CHE_PORT}"
      info "start" "API: http://${CHE_HOST}:${CHE_PORT}/swagger"
    else
      info "start" "Use: http://localhost:${CHE_PORT}"
      info "start" "API: http://localhost:${CHE_PORT}/swagger"
    fi
  else
    error "(${CHE_MINI_PRODUCT_NAME} start): Timeout waiting for server. Run \"docker logs ${CHE_SERVER_CONTAINER_NAME}\" to inspect the issue."
    return 2
  fi
}

is_initialized() {
  debug $FUNCNAME
  if [[ -d "${CHE_CONTAINER_CONFIG_MANIFESTS_FOLDER}" ]] && \
     [[ -d "${CHE_CONTAINER_CONFIG_MODULES_FOLDER}" ]] && \
     [[ -f "${REFERENCE_CONTAINER_ENVIRONMENT_FILE}" ]]; then
    return 0
  else
    return 1
  fi
}

is_configured() {
  debug $FUNCNAME
  if [[ -d "${CHE_CONTAINER_INSTANCE}" ]] && \
     [[ -f "${CHE_CONTAINER_INSTANCE}"/$CHE_VERSION_FILE ]]; then
    return 0
  else
    return 1
  fi
}

has_version_registry() {
  if [ -d /version/$1 ]; then
    return 0;
  else
    return 1;
  fi
}

list_versions(){
  # List all subdirectories and then print only the file name
  for version in /version/* ; do
    text " ${version##*/}\n"
  done
}

version_error(){
  text "\nWe could not find version '$1'. Available versions:\n"
  list_versions
  text "\nSet CHE_VERSION=<version> and rerun.\n\n"
}

### Returns the list of Codenvy images for a particular version of Codenvy
### Sets the images as environment variables after loading from file
get_image_manifest() {
  info "cli" "Checking registry for version '$1' images"
  if ! has_version_registry $1; then
    version_error $1
    return 1;
  fi

  IMAGE_LIST=$(cat /version/$1/images)
  IFS=$'\n'
  for SINGLE_IMAGE in $IMAGE_LIST; do
    log "eval $SINGLE_IMAGE"
    eval $SINGLE_IMAGE
  done
}

get_installed_version() {
  if ! is_configured; then
    echo "<not-configed>"
  else
    cat "${CHE_CONTAINER_INSTANCE}"/$CHE_VERSION_FILE
  fi
}

get_configured_version() {
  if ! is_initialized; then
    echo "<not-initialized>"
  else
     cat "${CHE_CONTAINER_CONFIG}"/$CHE_VERSION_FILE
  fi
}

get_image_version() {
  echo "$CHE_IMAGE_VERSION"
}

less_than() {
  for (( i=0; i<${#1}; i++ )); do
    if [[ ${1:$i:1} != ${2:$i:1} ]]; then
      if [ ${1:$i:1} -lt ${2:$i:1} ]; then
        return 0
      fi
    fi 
  done
  return 1
}

compare_cli_version_to_configured_version() {
  IMAGE_VERSION=$(get_image_version)
  CONFIGURED_VERSION=$(get_configured_version)

  ## First, compare the CLI image version to what version was initialized in /config/*.ver.do_not_modify
  ##      - If they match, good
  ##      - If they don't match and one is nightly, fail
  ##      - If they don't match, then if CLI is older fail with message to get proper CLI
  ##      - If they don't match, then if CLI is newer fail with message to run upgrade first
  if [[ "$CONFIGURED_VERSION" = "$IMAGE_VERSION" ]]; then
    echo "match"
  elif [ "$CONFIGURED_VERSION" = "nightly" ] ||
       [ "$IMAGE_VERSION" = "nightly" ]; then
    echo "nightly"
  elif less_than $CONFIGURED_VERSION $IMAGE_VERSION; then
    echo "config-less-cli"
  else
    echo "cli-less-config"
  fi
}

compare_installed_version_to_configured_version() {
  CONFIGURED_VERSION=$(get_configured_version)
  INSTALLED_VERSION=$(get_installed_version)

  ## Second, compare /config/*.ver.donotmofiy to /instance/*.ver.donotmodify
  ##      - If they match, then continue
  ##      - If they do not match, then if .env is newer, then fail with message to run upgrade first
  ##      - If they do not match, then if .env is older, then fail with message that this is not good
  if [[ "$CONFIGURED_VERSION" = "$INSTALLED_VERSION" ]]; then
    echo "match"
  elif less_than $CONFIGURED_VERSION $INSTALLED_VERSION; then
    echo "config-less-install"
  else
    echo "install-less-config"
  fi
}

verify_version_compatibility() {
  ## Two levels of checks
  ## First, compare the CLI image version to what version was initialized in /config/*.ver.do_not_modify
  ##      - If they match, good
  ##      - If they don't match and one is nightly, fail
  ##      - If they don't match, then if CLI is older fail with message to get proper CLI
  ##      - If they don't match, then if CLLI is newer fail with message to run upgrade first
  ## Second, compare /config/*.ver.donotmofiy to /instance/*.ver.do_not_modify
  ##      - If they match, then continue
  ##      - If they do not match, then if .env is newer, then fail with message to run upgrade first
  ##      - If they do not match, then if .env is older, then fail with message that this is not good 

  CHE_IMAGE_VERSION=$(get_image_version)

  if is_initialized; then
    COMPARE_CLI_ENV=$(compare_cli_version_to_configured_version)
    CONFIGURED_VERSION=$(get_configured_version)

    case "${COMPARE_CLI_ENV}" in
      "match") 
      ;;
      "nightly")
        error ""
        error "Your CLI version '${CHE_MINI_PRODUCT_NAME}/cli:$CHE_IMAGE_VERSION' does not match your configured version '$CONFIGURED_VERSION'."
        error ""
        error "The 'nightly' CLI is only compatible with 'nightly' configured versions."
        error "You may not '${CHE_MINI_PRODUCT_NAME} upgrade' from 'nightly' to a tagged version."
        error ""
        error "Run the CLI as '${CHE_MINI_PRODUCT_NAME}/cli:<version>' to install a tagged version."
        return 2
      ;;
      "config-less-cli")
        error ""
        error "Your CLI version '${CHE_MINI_PRODUCT_NAME}/cli:$CHE_IMAGE_VERSION' is newer than your configured version '$CONFIGURED_VERSION'."
        error ""
        error "Run '${CHE_MINI_PRODUCT_NAME}/cli:$CHE_IMAGE_VERSION upgrade' to migrate your installation to '$CHE_IMAGE_VERSION'."
        error "Or, run the CLI with '${CHE_MINI_PRODUCT_NAME}/cli:$CONFIGURED_VERSION' to have the CLI match your existing installed version."
        return 2
      ;;
      "cli-less-config")
        error ""
        error "Your CLI version '${CHE_MINI_PRODUCT_NAME}/cli:$CHE_IMAGE_VERSION' is older than your configured version '$CONFIGURED_VERSION'."
        error ""
        error "You cannot use an older CLI with a newer configuration."
        error ""
        error "Run the CLI with '${CHE_MINI_PRODUCT_NAME}/cli:$CONFIGURED_VERSION' to have the CLI match your existing installed version."
        return 2
      ;;
    esac
  fi


  # Scenario #2 should only be checked if the system is already configured
  if is_configured; then
    COMPARE_INSTALL_ENV=$(compare_installed_version_to_configured_version)
    INSTALLED_VERSION=$(get_installed_version)
    case "${COMPARE_INSTALL_ENV}" in
      "match")
      ;;
      "config-less-install"|"install-less-config")
        error ""
        error "Your CLI version '$CHE_IMAGE_VERSION' matches your configed version (good), but:"
        error "   Configured version = '$CONFIGURED_VERSION'"
        error "   Installed version  = '$INSTALLED_VERSION'"
        error ""
        error "The configured and installed versions must match before other operations proceed."
        error ""
        error "Run '$CHE_MINI_PRODUCT_NAME/cli:${INSTALLED_VERSION} init --reinit' to configure the proper version."
        error ""
        error "We could automatically do this for you."
        error "However, having configured and installed versions mismatch is unusual and should be checked by a human."
        return 2
      ;;
    esac
  fi
}

verify_version_upgrade_compatibility() {
  ## Two levels of checks
  ## First, compare the CLI image version to what the admin has configured in /config/.env file
  ##      - If they match, nothing to upgrade
  ##      - If they don't match and one is nightly, fail upgrade is not supported for nightly
  ##      - If they don't match, then if CLI is older fail with message that we do not support downgrade
  ##      - If they don't match, then if CLI is newer then good
  ## Second, compare proposed .env version to already installed version
  ##      - If they match, then ok to upgrade, we will update the ENV file 
  ##      - If they do not match, then if .env is newer, then fail with message that ENV file & install must match before upgrade
  ##      - If they do not match, then if .env is older, then fail with message that ENV file & install must match before upgrade 

  CHE_IMAGE_VERSION=$(get_image_version)

  if ! is_initialized || ! is_configed; then 
    info "upgrade" "$CHE_MINI_PRODUCT_NAME is not installed or configured. Nothing to upgrade."
    return 2
  fi

  if is_initialized; then
    COMPARE_CLI_ENV=$(compare_cli_version_to_envfile_version)
    ENV_FILE_VERSION=$(get_envfile_version)

    case "${COMPARE_CLI_ENV}" in
      "match") 
        error ""
        error "Your CLI version '${CHE_MINI_PRODUCT_NAME}/cli:$CHE_IMAGE_VERSION' is identical to your configured version '$ENV_FILE_VERSION'."
        error ""
        error "Run '$CHE_MINI_PRODUCT_NAME/cli:<version> upgrade>' with a newer version to upgrade."
        error "View all available versions: https://hub.docker.com/r/$CHE_MINI_PRODUCT_NAME/cli/tags/."
        return 2
      ;;
      "nightly")
        error ""
        error "Your CLI version '${CHE_MINI_PRODUCT_NAME}/cli:$CHE_IMAGE_VERSION' or configured version '$ENV_FILE_VERSION' is nightly."
        error ""
        error "You may not '${CHE_MINI_PRODUCT_NAME} upgrade' from 'nightly' to a non-nightly version."
        error "You can 'docker pull ${CHE_MINI_PRODUCT_NAME}/cli:nightly' to get a newer nightly version."
        return 2
      ;;
      "envfile-less-cli")
      ;;
      "cli-less-envfile")
        error ""
        error "Your CLI version '${CHE_MINI_PRODUCT_NAME}/cli:$CHE_IMAGE_VERSION' is older than your configured version '$ENV_FILE_VERSION'."
        error ""
        error "You cannot upgrade to an older version."
        error ""
        error "Run '$CHE_MINI_PRODUCT_NAME/cli:<version> upgrade>' with a newer version to upgrade."
        error "View all available versions: https://hub.docker.com/r/$CHE_MINI_PRODUCT_NAME/cli/tags/."
        return 2
      ;;
    esac
  fi

  # Scenario #2 should only be checked if the system is already configured
  if is_configed; then
    COMPARE_INSTALL_ENV=$(compare_installed_version_to_envfile_version)
    INSTALLED_VERSION=$(get_installed_version)
    case "${COMPARE_INSTALL_ENV}" in
      "match") 
      ;;
      "envfile-less-install"|"install-less-envfile")
        error ""
        error "Your CLI version '$CHE_IMAGE_VERSION' is newer (good), but:"
        error "   Configured version = '$ENV_FILE_VERSION'"
        error "   Installed version  = '$INSTALLED_VERSION'"
        error ""
        error "The configured and installed versions must match before upgrade proceeds."
        error ""
        error "Modify '${CHE_HOST_CONFIG}/${CHE_ENVIRONMENT_FILE}' to match your configured version to your installed version '$INSTALLED_VERSION'."
        error "Then run '$CHE_MINI_PRODUCT_NAME/cli:<version> upgrade>' with a newer Docker image to initiate an upgrade."
        error ""
        error "We could automatically make this change."
        error "However, having configured and installed version be different is unusual and should be checked by a human."
        return 2
      ;;
    esac
  fi
}

# Usage:
#   confirm_operation <Warning message> [--force|--no-force]
confirm_operation() {
  debug $FUNCNAME

  FORCE_OPERATION=${2:-"--no-force"}

  if [ ! "${FORCE_OPERATION}" == "--quiet" ]; then
    # Warn user with passed message
    info "${1}"
    text "\n"
    read -p "      Are you sure? [N/y] " -n 1 -r
    text "\n\n"
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      return 1;
    else
      return 0;
    fi
  fi
}
