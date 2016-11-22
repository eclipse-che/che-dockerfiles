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

cmd_destroy() {
  debug $FUNCNAME

  QUIET=""
  DESTROY_CLI="false"

  while [ $# -gt 0 ]; do
    case $1 in
      --quiet)
        QUIET="--quiet"
        shift ;;
      --cli)
        DESTROY_CLI="true"
        shift ;;
      *) error "Unknown parameter: $1" ; return 2 ;;
    esac
  done

  WARNING="destroy !!! Stopping services and !!! deleting data !!! this is unrecoverable !!!"
  if ! confirm_operation "${WARNING}" "${QUIET}"; then
    return;
  fi

  cmd_stop

  info "destroy" "Deleting instance and config..."
  log "docker_run -v \"${CHE_HOST_CONFIG}\":/${CHE_MINI_PRODUCT_NAME}-config -v \"${CHE_HOST_INSTANCE}\":/${CHE_MINI_PRODUCT_NAME}-instance alpine:3.4 sh -c \"rm -rf /root/codenvy-instance/* && rm -rf /root/codenvy-config/*\""
  docker_run -v "${CHE_HOST_CONFIG}":/root/${CHE_MINI_PRODUCT_NAME}-config \
             -v "${CHE_HOST_INSTANCE}":/root/${CHE_MINI_PRODUCT_NAME}-instance \
                alpine:3.4 sh -c "rm -rf /root/${CHE_MINI_PRODUCT_NAME}-instance/* && rm -rf /root/${CHE_MINI_PRODUCT_NAME}-config/*"

  rm -rf "${CHE_CONTAINER_CONFIG}"
  rm -rf "${CHE_CONTAINER_INSTANCE}"

  # Sometimes users want the CLI after they have destroyed their instance
  # If they pass destroy --cli then we will also destroy the CLI
  if [[ "${DESTROY_CLI}" = "true" ]]; then
    if [[ "${CLI_MOUNT}" = "not set" ]]; then
      info "destroy" "Did not delete cli.log - ':/cli' not mounted"
    else
      info "destroy" "Deleting cli.log..."
      docker_run -v "${CLI_MOUNT}":/root/cli alpine:3.4 sh -c "rm -rf /root/cli/cli.log"
    fi
  fi
}
