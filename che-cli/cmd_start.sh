#!/bin/bash
# Copyright (c) 2012-2016 Codenvy, S.A.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
#
# Contributors:
#   Tyler Jewell - Initial Implementation
#

cmd_start() {
  debug $FUNCNAME

  # If Eclipse Che is already started or booted, then terminate early.
  if container_exist_by_name $CHE_SERVER_CONTAINER_NAME; then
    CURRENT_CHE_SERVER_CONTAINER_ID=$(get_server_container_id $CHE_SERVER_CONTAINER_NAME)
    if container_is_running ${CURRENT_CHE_SERVER_CONTAINER_ID} && \
       server_is_booted ${CURRENT_CHE_SERVER_CONTAINER_ID}; then
       info "start" "$CHE_MINI_PRODUCT_NAME is already running"
       info "start" "Server logs at \"docker logs -f ${CHE_SERVER_CONTAINER_NAME}\""
       info "start" "Ver: $(get_installed_version)"
       if ! is_docker_for_mac; then
         info "start" "Use: http://${CHE_HOST}:${CHE_PORT}"
         info "start" "API: http://${CHE_HOST}:${CHE_PORT}/swagger"
       else
         info "start" "Use: http://localhost:${CHE_PORT}"
         info "start" "API: http://localhost:${CHE_PORT}/swagger"
       fi
       return
    fi
  fi

  # To protect users from accidentally updating their Codenvy servers when they didn't mean
  # to, which can happen if CHE_VERSION=latest
  FORCE_UPDATE=${1:-"--no-force"}
  # Always regenerate puppet configuration from environment variable source, whether changed or not.
  # If the current directory is not configured with an .env file, it will initialize
  cmd_config $FORCE_UPDATE

  # Begin tests of open ports that we require
  info "start" "Preflight checks"
  text   "         port ${CHE_PORT} (http):       $(port_open ${CHE_PORT} && echo "${GREEN}[AVAILABLE]${NC}" || echo "${RED}[ALREADY IN USE]${NC}") \n"
  if ! $(port_open ${CHE_PORT}); then
    echo ""
    error "Ports required to run $CHE_MINI_PRODUCT_NAME are used by another program."
    return 1;
  fi
  text "\n"

  # Start Eclipse Che
  # Note bug in docker requires relative path, not absolute path to compose file
  info "start" "Starting containers..."
  log "docker_compose --file=\"${REFERENCE_CONTAINER_COMPOSE_FILE}\" -p=$CHE_MINI_PRODUCT_NAME up -d >> \"${LOGS}\" 2>&1"
  docker_compose --file="${REFERENCE_CONTAINER_COMPOSE_FILE}" \
                 -p=$CHE_MINI_PRODUCT_NAME up -d >> "${LOGS}" 2>&1
  check_if_booted
}
