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

cmd_init() {

  # set an initial value for the flag
  FORCE_UPDATE="--no-force"
  AUTO_ACCEPT_LICENSE="false"
  REINIT="false"

  while [ $# -gt 0 ]; do
    case $1 in
      --no-force|--force|--pull|--offline)
        FORCE_UPDATE=$1
        shift ;;
      --accept-license)
        AUTO_ACCEPT_LICENSE="true"
        shift ;;
      --reinit)
        REINIT="true"
        shift ;;
      *) error "Unknown parameter: $1" ; return 2 ;;
    esac
  done

  if [ "${FORCE_UPDATE}" == "--no-force" ]; then
    # If che.environment file exists, then fail
    if is_initialized; then
      if [[ "${REINIT}" = "false" ]]; then
        info "init" "Already initialized."
        return 2
      fi
    fi
  fi

  if [[ "${CHE_IMAGE_VERSION}" = "nightly" ]]; then
    warning "($CHE_MINI_PRODUCT_NAME init): 'nightly' installations cannot be upgraded to non-nightly versions"
  fi

  cmd_download $FORCE_UPDATE

  if [ -z ${IMAGE_INIT+x} ]; then
    get_image_manifest $CHE_VERSION
  fi

  info "init" "Installing configuration and bootstrap variables:"
  log "mkdir -p \"${CHE_CONTAINER_CONFIG}\""
  mkdir -p "${CHE_CONTAINER_CONFIG}"
  log "mkdir -p \"${CHE_CONTAINER_INSTANCE}\""
  mkdir -p "${CHE_CONTAINER_INSTANCE}"

  if [ ! -w "${CHE_CONTAINER_CONFIG}" ]; then
    error "CHE_CONTAINER_CONFIG is not writable. Aborting."
    return 1;
  fi

  if [ ! -w "${CHE_CONTAINER_INSTANCE}" ]; then
    error "CHE_CONTAINER_INSTANCE is not writable. Aborting."
    return 1;
  fi

  # in development mode we use init files from repo otherwise we use it from docker image
  if [ "${CHE_DEVELOPMENT_MODE}" = "on" ]; then
    docker_run -v "${CHE_HOST_CONFIG}":/copy \
               -v "${CHE_HOST_DEVELOPMENT_REPO}/che-init":/files \
                   $IMAGE_INIT
  else
    docker_run -v "${CHE_HOST_CONFIG}":/copy $IMAGE_INIT
  fi

  # If this is a reinit, we should not overwrite these core template files.
  # If this is an initial init, then we have to override some values
  if [[ "${REINIT}" = "false" ]]; then
    # Otherwise, we are using the templated version and making some modifications.
    sed -i'.bak' "s|#CHE_HOST=.*|CHE_HOST=${CHE_HOST}|" "${REFERENCE_CONTAINER_ENVIRONMENT_FILE}"
    rm -rf "${REFERENCE_CONTAINER_ENVIRONMENT_FILE}".bak > /dev/null 2>&1

    info "init" "  CHE_HOST=${CHE_HOST}"
    info "init" "  CHE_VERSION=${CHE_VERSION}"
    info "init" "  CHE_CONFIG=${CHE_HOST_CONFIG}"
    info "init" "  CHE_INSTANCE=${CHE_HOST_INSTANCE}"
    if [ "${CHE_DEVELOPMENT_MODE}" == "on" ]; then
      info "init" "  CHE_ENVIRONMENT=development"
      info "init" "  CHE_DEVELOPMENT_REPO=${CHE_HOST_DEVELOPMENT_REPO}"
      info "init" "  CHE_ASSEMBLY=${CHE_ASSEMBLY}"
    else
      info "init" "  CHE_ENVIRONMENT=production"
    fi
  fi

  # Encode the version that we initialized into the version file
  echo "$CHE_VERSION" > "${CHE_CONTAINER_INSTANCE}/${CHE_VERSION_FILE}"
}

require_license() {
  if [[ "${CHE_LICENSE}" = "true" ]]; then
    return 0
  else
    return 1
  fi
}
