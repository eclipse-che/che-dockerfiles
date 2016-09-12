#!/bin/sh
# Copyright (c) 2012-2016 Codenvy, S.A., Red Hat, Inc
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
#
# Contributors:
#   Mario Loriedo - Initial implementation
#

usage () {
  printf "%s" "${USAGE}"
}

info() {
  printf  "${GREEN}INFO:${NC} %s\n" "${1}"
}

debug() {
  printf  "${BLUE}DEBUG:${NC} %s\n" "${1}"
}

error() {
  printf  "${RED}ERROR:${NC} %s\n" "${1}"
}

error_exit() {
  echo  "---------------------------------------"
  error "!!!"
  error "!!! ${1}"
  error "!!!"
  echo  "---------------------------------------"
  exit 1
}

convert_windows_to_posix() {
  # "/some/path" => /some/path
  OUTPUT_PATH=${1//\"}
  echo "/"$(echo "$OUTPUT_PATH" | sed 's/\\/\//g' | sed 's/://')
}

get_clean_path() {
  INPUT_PATH=$1
  # \some\path => /some/path
  OUTPUT_PATH=$(echo ${INPUT_PATH} | tr '\\' '/')
  # /somepath/ => /somepath
  OUTPUT_PATH=${OUTPUT_PATH%/}
  # /some//path => /some/path
  OUTPUT_PATH=$(echo ${OUTPUT_PATH} | tr -s '/')
  # "/some/path" => /some/path
  OUTPUT_PATH=${OUTPUT_PATH//\"}
  echo ${OUTPUT_PATH}
}

get_converted_and_clean_path() {
  CONVERTED_PATH=$(convert_windows_to_posix "${1}")
  CLEAN_PATH=$(get_clean_path "${CONVERTED_PATH}")
  echo $CLEAN_PATH
}

get_che_launcher_container_id() {
  hostname
}

get_che_launcher_version() {
  if [ -n "${LAUNCHER_IMAGE_VERSION}" ]; then
    echo "${LAUNCHER_IMAGE_VERSION}"
  else
    echo "latest"
  fi
}

is_boot2docker() {
  if uname -r | grep -q 'boot2docker'; then
    return 0
  else
    return 1
  fi
}

has_docker_for_windows_ip() {
  if [ "${ETH0_ADDRESS}" = "10.0.75.2" ]; then
    return 0
  else
    return 1
  fi
}

is_docker_for_mac() {
  if uname -r | grep -q 'moby' && ! has_docker_for_windows_ip; then
    return 0
  else
    return 1
  fi
}

is_docker_for_windows() {
  if uname -r | grep -q 'moby' && has_docker_for_windows_ip; then
    return 0
  else
    return 1
  fi
}

docker_run() {
   ENV_FILE=$(get_list_of_che_system_environment_variables)
   docker run -d --name "${CHE_SERVER_CONTAINER_NAME}" \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /home/user/che/lib:/home/user/che/lib-copy \
    -p "${CHE_PORT}":8080 \
    --restart="${CHE_RESTART_POLICY}" \
    --user="${CHE_USER}" \
    --env-file=$ENV_FILE \
    -v "$CHE_STORAGE_LOCATION" "$@"
 
   rm -rf $ENV_FILE > /dev/null
}

docker_run_with_storage() {
  if is_docker_for_mac || is_docker_for_windows || is_boot2docker; then
    # If on docker for mac or windows, then we have to use these special parameters
    docker_run -e "CHE_WORKSPACE_STORAGE=$CHE_DATA_FOLDER/workspaces" \
               -e "CHE_WORKSPACE_STORAGE_CREATE_FOLDERS=false" "$@"
  else
    # Otherwise, mount the full directory
    docker_run -v "$CHE_WORKSPACE_LOCATION" "$@"
  fi
}

docker_run_with_local_binary() {
  if has_local_binary_path; then
    docker_run_with_storage -v "$CHE_LOCAL_BINARY_LOCATION" "$@"
  else
    docker_run_with_storage "$@"
  fi
}

docker_run_with_conf() {
  if has_che_conf_path; then
    docker_run_with_local_binary -v "$CHE_CONF_LOCATION" -e "CHE_LOCAL_CONF_DIR=/conf" "$@"
  else
    docker_run_with_local_binary "$@"
  fi
}

docker_run_with_privileges() {
  if is_docker_for_mac; then
    docker_run_with_conf --privileged "$@"
  else
    docker_run_with_conf "$@"
  fi
}

docker_run_with_debug() {
  if has_debug && has_debug_suspend; then
    docker_run_with_privileges -p "${CHE_DEBUG_SERVER_PORT}":8000 -e "JPDA_SUSPEND=y" "$@"
  elif has_debug; then
    docker_run_with_privileges -p "${CHE_DEBUG_SERVER_PORT}":8000 "$@"
  else
    docker_run_with_privileges "$@"
  fi
}

has_debug_suspend() {
  if [ "${CHE_DEBUG_SERVER_SUSPEND}" = "false" ]; then
    return 1
  else
    return 0
  fi
}

has_debug() {
  if [ "${CHE_DEBUG_SERVER}" = "false" ]; then
    return 1
  else
    return 0
  fi
}

has_che_conf_path() {
  if [ "${CHE_CONF_FOLDER}" = "" ]; then
    return 1
  else
    return 0
  fi
}

has_local_binary_path() {
  if [ "${CHE_LOCAL_BINARY}" = "" ]; then
    return 1
  else
    return 0
  fi
}

add_iptables_rules() {
  APK_UPDATE="apk update"
  INSTALL_IPTABLES="apk add iptables"
  ALLOW_LO_RULE="sysctl -w net.ipv4.conf.eth0.route_localnet=1"
  IP_TABLE_RULE1="iptables -t nat -A OUTPUT -p tcp -d localhost -o lo --dport 32000:65000 -j DNAT --to ${CHE_HOST_IP}:32000-65000"
  IP_TABLE_RULE2="iptables -t nat -A POSTROUTING -o eth0 -m addrtype --src-type LOCAL --dst-type UNICAST -j MASQUERADE"

  if ! docker exec ${CHE_SERVER_CONTAINER_NAME} ${APK_UPDATE} > /dev/null 2>&1; then
    output=$(docker exec ${CHE_SERVER_CONTAINER_NAME} ${APK_UPDATE})
    error_exit "Error when running \"docker exec ${CHE_SERVER_CONTAINER_NAME} ${APK_UPDATE}\": ${output}"
  fi

  if ! docker exec ${CHE_SERVER_CONTAINER_NAME} ${INSTALL_IPTABLES} > /dev/null 2>&1; then
    output=$(docker exec ${CHE_SERVER_CONTAINER_NAME} ${INSTALL_IPTABLES})
    error_exit "Error when running \"docker exec ${CHE_SERVER_CONTAINER_NAME} ${INSTALL_IPTABLES}\": ${output}"
  fi

  if ! docker exec ${CHE_SERVER_CONTAINER_NAME} ${ALLOW_LO_RULE} > /dev/null 2>&1; then
    output=$(docker exec ${CHE_SERVER_CONTAINER_NAME} ${ALLOW_LO_RULE})
    error_exit "Error when running \"docker exec ${CHE_SERVER_CONTAINER_NAME} ${ALLOW_LO_RULE}\": ${output}"
  fi

  if ! docker exec ${CHE_SERVER_CONTAINER_NAME} ${IP_TABLE_RULE1} > /dev/null 2>&1; then
    output=$(docker exec ${CHE_SERVER_CONTAINER_NAME} ${IP_TABLE_RULE1})
    error_exit "Error when running \"docker exec ${CHE_SERVER_CONTAINER_NAME} ${IP_TABLE_RULE1}\": ${output}"
  fi

  if ! docker exec ${CHE_SERVER_CONTAINER_NAME} ${IP_TABLE_RULE2} > /dev/null 2>&1; then
    output=$(docker exec ${CHE_SERVER_CONTAINER_NAME} ${IP_TABLE_RULE2})
    error_exit "Error when running \"docker exec ${CHE_SERVER_CONTAINER_NAME} ${IP_TABLE_RULE2}\": ${output}"
  fi
}

get_list_of_che_system_environment_variables() {
  # See: http://stackoverflow.com/questions/4128235/what-is-the-exact-meaning-of-ifs-n
  IFS=$'\n'
  
  DOCKER_ENV=$(mktemp)

  # First grab all known CHE_ variables
  CHE_VARIABLES=$(env | grep CHE_)
  for SINGLE_VARIABLE in "${CHE_VARIABLES}"; do
    echo "${SINGLE_VARIABLE}" >> $DOCKER_ENV
  done
  

  # Add in known proxy variables
  if [ ! -z ${http_proxy+x} ]; then 
    echo "http_proxy=${http_proxy}" >> $DOCKER_ENV
  fi

  if [ ! -z ${https_proxy+x} ]; then 
    echo "https_proxy=${https_proxy}" >> $DOCKER_ENV
  fi

  if [ ! -z ${no_proxy+x} ]; then 
    echo "no_proxy=${no_proxy}" >> $DOCKER_ENV
  fi

  echo $DOCKER_ENV
}


get_docker_install_type() {
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

get_docker_host_ip() {
  case $(get_docker_install_type) in
   boot2docker)
     echo $ETH1_ADDRESS
   ;;
   native)
     echo $DOCKER0_ADDRESS
   ;;
   *)
     echo $ETH0_ADDRESS
   ;;
  esac
}

get_docker_host_os() {
  docker info | grep "Operating System:" | sed "s/^Operating System: //"
}

get_docker_daemon_version() {
  docker version | grep -i "server version:" | sed "s/^server version: //I"
}

get_che_hostname() {
  INSTALL_TYPE=$(get_docker_install_type)
  if [ "${INSTALL_TYPE}" = "boot2docker" ]; then
    echo $DEFAULT_DOCKER_HOST_IP
  else
    echo "localhost"
  fi
}

check_docker() {
  if [ ! -S /var/run/docker.sock ]; then
    error_exit "Docker socket (/var/run/docker.sock) hasn't be mounted \
inside the container. Verify the syntax of the \"docker run\" command."
  fi

  if ! docker ps > /dev/null 2>&1; then
    output=$(docker ps)
    error_exit "Error when running \"docker ps\": ${output}"
  fi
}

che_container_exist() {
  if [ "$(docker ps -aq  -f "name=${CHE_SERVER_CONTAINER_NAME}" | wc -l)" -eq 0 ]; then
    return 1
  else
    return 0
  fi
}

che_container_is_running() {
  if [ "$(docker ps -qa -f "status=running" -f "name=${CHE_SERVER_CONTAINER_NAME}" | wc -l)" -eq 0 ]; then
    return 1
  else
    return 0
  fi
}

che_container_is_stopped() {
  if [ "$(docker ps -qa -f "status=exited" -f "name=${CHE_SERVER_CONTAINER_NAME}" | wc -l)" -eq 0 ]; then
    return 1
  else
    return 0
  fi
}


get_che_container_host_bind_folder() {
  BINDS=$(docker inspect --format="{{.HostConfig.Binds}}" "${CHE_SERVER_CONTAINER_NAME}" | cut -d '[' -f 2 | cut -d ']' -f 1)

  for SINGLE_BIND in $BINDS; do
    case $SINGLE_BIND in
      *$1*)
        echo $SINGLE_BIND | cut -f1 -d":"
      ;;
      *)
      ;;
    esac
  done
}

get_che_container_conf_folder() {
  FOLDER=$(get_che_container_host_bind_folder "/conf")
  echo "${FOLDER:=not set}"
}

get_che_container_data_folder() {
  FOLDER=$(get_che_container_host_bind_folder "/home/user/che/workspaces")
  echo "${FOLDER:=not set}"
}

get_che_container_image_name() {
  docker inspect --format="{{.Config.Image}}" "${CHE_SERVER_CONTAINER_NAME}"
}

get_che_server_container_id() {
  docker ps -q -a -f "name=${CHE_SERVER_CONTAINER_NAME}"
}

wait_until_container_is_running() {
  CONTAINER_START_TIMEOUT=${1}

  ELAPSED=0
  until che_container_is_running || [ ${ELAPSED} -eq "${CONTAINER_START_TIMEOUT}" ]; do
    sleep 1
    ELAPSED=$((ELAPSED+1))
  done
}

wait_until_container_is_stopped() {
  CONTAINER_STOP_TIMEOUT=${1}

  ELAPSED=0
  until che_container_is_stopped || [ ${ELAPSED} -eq "${CONTAINER_STOP_TIMEOUT}" ]; do
    sleep 1
    ELAPSED=$((ELAPSED+1))
  done
}

server_is_booted() {
  HTTP_STATUS_CODE=$(curl -I http://$(docker inspect -f '{{.NetworkSettings.IPAddress}}' "${CHE_SERVER_CONTAINER_NAME}"):8080/api/ \
                     -s -o /dev/null --write-out "%{http_code}")
  if [ "${HTTP_STATUS_CODE}" = "200" ]; then
    return 0
  else
    return 1
  fi
}

wait_until_server_is_booted () {
  SERVER_BOOT_TIMEOUT=${1}

  ELAPSED=0
  until server_is_booted || [ ${ELAPSED} -eq "${SERVER_BOOT_TIMEOUT}" ]; do
    sleep 1
    ELAPSED=$((ELAPSED+1))
  done
}

execute_command_with_progress() {
  progress=$1
  command=$2
  shift 2

  pid=""

  case "$progress" in
    extended)
      $command "$@"
      ;;
    basic|*)
      $command "$@" &>/dev/null &
      pid=$!
      while kill -0 "$pid" >/dev/null 2>&1; do
        printf "#"
        sleep 10
      done
      wait $pid # return pid's exit code
      printf "\n"
    ;;
  esac
  printf "\n"
}
