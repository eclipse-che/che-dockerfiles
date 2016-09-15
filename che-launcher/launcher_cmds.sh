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

start_che_server() {
  if che_container_exist; then
    error_exit "
           A container running ${CHE_PRODUCT_NAME} named \"${CHE_SERVER_CONTAINER_NAME}\" already exists.
             1. Use \"info\" to find it's URL.
             2. Use \"restart\" to stop it and start anew.
             3. Stop it with \"stop\".
             4. Remove it manually (docker rm -f ${CHE_SERVER_CONTAINER_NAME}) and try again. Or:
             5. Set CHE_SERVER_CONTAINER_NAME to a different value and try again."
  fi

  CURRENT_IMAGE=$(docker images -q "${CHE_SERVER_IMAGE_NAME}":"${CHE_VERSION}")

  if [ "${CURRENT_IMAGE}" != "" ]; then
    info "${CHE_PRODUCT_NAME}: Found image ${CHE_SERVER_IMAGE_NAME}:${CHE_VERSION}"
  else
    update_che_server
  fi

  info "${CHE_PRODUCT_NAME}: Starting container..."
  docker_run_with_debug "${CHE_SERVER_IMAGE_NAME}":"${CHE_VERSION}" \
                          --remote:"${CHE_HOST_IP}" \
                          -s:uid \
                          -s:client \
                          ${CHE_DEBUG_OPTION} \
                          run > /dev/null

  wait_until_container_is_running 10
  if ! che_container_is_running; then
    error_exit "${CHE_PRODUCT_NAME}: Timeout waiting for ${CHE_PRODUCT_NAME} container to start."
  fi

  info "${CHE_PRODUCT_NAME}: Server logs at \"docker logs -f ${CHE_SERVER_CONTAINER_NAME}\""
  info "${CHE_PRODUCT_NAME}: Server booting..."
  wait_until_server_is_booted 60

  if server_is_booted; then
    info "${CHE_PRODUCT_NAME}: Booted and reachable"
    info "${CHE_PRODUCT_NAME}: Use: http://${CHE_HOST_IP}:${CHE_PORT}"
    info "${CHE_PRODUCT_NAME}: API: http://${CHE_HOST_IP}:${CHE_PORT}/swagger"

    if has_debug; then
      info "${CHE_PRODUCT_NAME}: JPDA Debug - http://${CHE_HOST_IP}:${CHE_DEBUG_SERVER_PORT}"
    fi
  else
    error_exit "${CHE_PRODUCT_NAME}: Timeout waiting for server. Run \"docker logs ${CHE_SERVER_CONTAINER_NAME}\" to inspect the issue."
  fi
}

stop_che_server() {
  if ! che_container_is_running; then
    info "${CHE_PRODUCT_NAME}: Container is not running. Nothing to do."
  else
    info "${CHE_PRODUCT_NAME}: Stopping server..."
    docker exec ${CHE_SERVER_CONTAINER_NAME} /home/user/che/bin/che.sh -c -s:uid stop > /dev/null
    wait_until_container_is_stopped 60
    if che_container_is_running; then
      error_exit "${CHE_PRODUCT_NAME}: Timeout waiting for the ${CHE_PRODUCT_NAME} container to stop."
    fi

    info "${CHE_PRODUCT_NAME}: Removing container"
    docker rm ${CHE_SERVER_CONTAINER_NAME} > /dev/null
    info "${CHE_PRODUCT_NAME}: Stopped"
  fi
}

restart_che_server() {
  if che_container_is_running; then
    stop_che_server
  fi
  start_che_server
}

update_che_server() {
  if [ -z "${CHE_VERSION}" ]; then
    CHE_VERSION=${DEFAULT_CHE_VERSION}
  fi

  info "${CHE_PRODUCT_NAME}: Pulling image ${CHE_SERVER_IMAGE_NAME}:${CHE_VERSION}"
  execute_command_with_progress extended docker pull ${CHE_SERVER_IMAGE_NAME}:${CHE_VERSION}
}

print_debug_info() {
  info "---------------------------------------"
  info "---------   LAUNCHER INFO  ------------"
  info "---------------------------------------"
  info ""
  info "---------  PLATFORM INFO  -------------"
  info "DOCKER_INSTALL_TYPE       = ${DOCKER_INSTALL_TYPE}"
  info "DOCKER_HOST_OS            = $(get_docker_host_os)"
  info "DOCKER_HOST_IP            = ${DEFAULT_DOCKER_HOST_IP}"
  info "DOCKER_HOST_EXTERNAL_IP   = ${DEFAULT_CHE_DOCKER_MACHINE_HOST_EXTERNAL:-not set}"
  info "DOCKER_DAEMON_VERSION     = $(get_docker_daemon_version)"
  info ""
  info ""
  info "--------- CHE INSTANCE INFO  ----------" 
  info "CHE CONTAINER EXISTS      = $(che_container_exist && echo "YES" || echo "NO")"
  info "CHE CONTAINER STATUS      = $(che_container_is_running && echo "running" || echo "stopped")"
  if che_container_is_running; then
    info "CHE SERVER STATUS         = $(server_is_booted && echo "running & api reachable" || echo "stopped")"
    info "CHE VERSION               = $(get_server_version)"
    info "CHE IMAGE                 = $(get_che_container_image_name)"
    info "CHE SERVER CONTAINER ID   = $(get_che_server_container_id)"
    info "CHE CONF FOLDER           = $(get_che_container_conf_folder)"
    info "CHE DATA FOLDER           = $(get_che_container_data_folder)"
    CURRENT_CHE_PORT=$(docker inspect --format='{{ (index (index .NetworkSettings.Ports "8080/tcp") 0).HostPort }}' ${CHE_SERVER_CONTAINER_NAME})
    info "CHE USE URL               = http://${CHE_HOST_IP}:${CURRENT_CHE_PORT}"  
    info "CHE API URL               = http://${CHE_HOST_IP}:${CURRENT_CHE_PORT}/swagger"
    if has_debug; then
      CURRENT_CHE_DEBUG_PORT=$(docker inspect --format='{{ (index (index .NetworkSettings.Ports "8000/tcp") 0).HostPort }}' ${CHE_SERVER_CONTAINER_NAME})
      info "CHE JPDA DEBUG URL      = http://${CHE_HOST_IP}:${CURRENT_CHE_DEBUG_PORT}"  
    fi
    info 'CHE LOGS                  = run `docker logs -f '${CHE_SERVER_CONTAINER_NAME}'`'
  fi
  info ""
  info ""
  info "----  CURRENT COMMAND LINE OPTIONS  ---" 
  info "CHE_PORT                  = ${CHE_PORT}"
  info "CHE_VERSION               = ${CHE_VERSION}"
  info "CHE_RESTART_POLICY        = ${CHE_RESTART_POLICY}"
  info "CHE_USER                  = ${CHE_USER}"
  info "CHE_HOST_IP               = ${CHE_HOST_IP}"
  info "CHE_LOG_LEVEL             = ${CHE_LOG_LEVEL}"
  info "CHE_DEBUG_SERVER          = ${CHE_DEBUG_SERVER}"
  info "CHE_DEBUG_SERVER_PORT     = ${CHE_DEBUG_SERVER_PORT}"
  info "CHE_HOSTNAME              = ${CHE_HOSTNAME}"
  info "CHE_DATA_FOLDER           = ${CHE_DATA_FOLDER}"
  info "CHE_CONF_FOLDER           = ${CHE_CONF_FOLDER:-not set}"
  info "CHE_LOCAL_BINARY          = ${CHE_LOCAL_BINARY:-not set}"
  info "CHE_SERVER_CONTAINER_NAME = ${CHE_SERVER_CONTAINER_NAME}"
  info "CHE_SERVER_IMAGE_NAME     = ${CHE_SERVER_IMAGE_NAME}"
}
