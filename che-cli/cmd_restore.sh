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

cmd_restore() {
  debug $FUNCNAME

  if [[ -d "${CHE_CONTAINER_CONFIG}" ]] || \
     [[ -d "${CHE_CONTAINER_INSTANCE}" ]]; then

    WARNING="Restoration overwrites existing configuration and data. Are you sure?"
    if ! confirm_operation "${WARNING}" "$@"; then
      return;
    fi
  fi

  if get_server_container_id "${CHE_SERVER_CONTAINER_NAME}" >> "${LOGS}" 2>&1; then
    error "Codenvy is running. Stop before performing a restore. Aborting"
    return;
  fi

  if [[ ! -f "${CHE_CONTAINER_BACKUP}/${CHE_CONFIG_BACKUP_FILE_NAME}" ]] || \
     [[ ! -f "${CHE_CONTAINER_BACKUP}/${CHE_INSTANCE_BACKUP_FILE_NAME}" ]]; then
    error "Backup files not found. To do restore please do backup first."
    return;
  fi

  # remove config and instance folders
  log "docker_run -v \"${CHE_HOST_CONFIG}\":/${CHE_MINI_PRODUCT_NAME}-config \
                  -v \"${CHE_HOST_INSTANCE}\":/${CHE_MINI_PRODUCT_NAME}-instance \
                    alpine:3.4 sh -c \"rm -rf /root/${CHE_MINI_PRODUCT_NAME}-instance/* \
                                   && rm -rf /root/${CHE_MINI_PRODUCT_NAME}-config/*\""
  docker_run -v "${CHE_HOST_CONFIG}":/root/${CHE_MINI_PRODUCT_NAME}-config \
             -v "${CHE_HOST_INSTANCE}":/root/${CHE_MINI_PRODUCT_NAME}-instance \
                alpine:3.4 sh -c "rm -rf /root/${CHE_MINI_PRODUCT_NAME}-instance/* \
                              && rm -rf /root/${CHE_MINI_PRODUCT_NAME}-config/*"
  log "rm -rf \"${CHE_CONTAINER_CONFIG}\" >> \"${LOGS}\""
  log "rm -rf \"${CHE_CONTAINER_INSTANCE}\" >> \"${LOGS}\""
  rm -rf "${CHE_CONTAINER_CONFIG}"
  rm -rf "${CHE_CONTAINER_INSTANCE}"

  info "restore" "Recovering configuration..."
  mkdir -p "${CHE_CONTAINER_CONFIG}"
  docker_run -v "${CHE_HOST_CONFIG}":/root/${CHE_MINI_PRODUCT_NAME}-config \
             -v "${CHE_HOST_BACKUP}/${CHE_CONFIG_BACKUP_FILE_NAME}":"/root/backup/${CHE_CONFIG_BACKUP_FILE_NAME}" \
             alpine:3.4 sh -c "tar xf /root/backup/${CHE_CONFIG_BACKUP_FILE_NAME} -C /root/${CHE_MINI_PRODUCT_NAME}-config"

  info "restore" "Recovering instance data..."
  mkdir -p "${CHE_CONTAINER_INSTANCE}"
  docker_run -v "${CHE_HOST_INSTANCE}":/root/${CHE_MINI_PRODUCT_NAME}-instance \
               -v "${CHE_HOST_BACKUP}/${CHE_INSTANCE_BACKUP_FILE_NAME}":"/root/backup/${CHE_INSTANCE_BACKUP_FILE_NAME}" \
               alpine:3.4 sh -c "tar xf /root/backup/${CHE_INSTANCE_BACKUP_FILE_NAME} -C /root/${CHE_MINI_PRODUCT_NAME}-instance"
}
