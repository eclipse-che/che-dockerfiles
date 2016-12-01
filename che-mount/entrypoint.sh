#!/bin/sh
# Copyright (c) 2016 Codenvy, S.A.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
#
# Contributors:
#   Tyler Jewell - Initial implementation
#
init_logging() {
  BLUE='\033[1;34m'
  GREEN='\033[0;32m'
  RED='\033[0;31m'
  NC='\033[0m'
}

init_global_variables() {

  USAGE="
Usage on Linux 
  docker run --rm -it --cap-add SYS_ADMIN --device /dev/fuse
            --name che-mount
            -v \${HOME}/.ssh:\${HOME}/.ssh
            -v /etc/group:/etc/group:ro 
            -v /etc/passwd:/etc/passwd:ro 
            -v <path-to-sync-profile>:/profile
            -u \$(id -u \${USER})
            -v <local-mount>/:/mnthost 
            eclipse/che-mount <workspace-id|workspace-name> 
            	[--url=<url>]
            	[--user=<user>]
            	[--password=<password>]
           
Usage on Mac or Windows:
  docker run --rm -it --cap-add SYS_ADMIN --device /dev/fuse
            --name che-mount 
            -v <path-to-sync-profile>:/profile
            -v <local-mount>/:/mnthost 
            eclipse/che-mount <workspace-id|workspace-name> 
            	[--url=<url>]
            	[--user=<user>]
            	[--password=<password>]

     <local-mount>    Host directory to sync files, must end with a slash '/'
     <url>            Defines the url to be used
     <user>           Username used to authenticate with server if required
     <password>       Password used to authenticate with server if required
     <workspace-id|workspace-name> ID or Name of the workspace or namespace:workspace-name
"
 UNISON_REPEAT_DELAY_IN_SEC=2
 WORKSPACE_NAME=
 COMMAND_EXTRA_ARGS=
 REMOTE_SYNC_FOLDER=/projects
 UNISON_ARGS="-batch -fat -silent -auto -prefer=newer -log=false"
 CHE_MINI_PRODUCT_NAME=che
 UNISON_COMMAND=
 UNISON_COMMAND_AGENT="unison /mnthost ssh://\${SSH_USER}@\${SSH_IP}:\${SSH_PORT}/\${REMOTE_SYNC_FOLDER} \
  -retry 10 \${UNISON_ARGS} -sshargs '-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no' > /dev/null 2>&1"
  
 UNISON_COMMAND_SSHFS="unison /mntssh /mnthost \${UNISON_ARGS} > /dev/null 2>&1"
 [ -t 0 ] && INTERACTIVE=false || INTERACTIVE=true
}

check_status() {
    status=$?
	if [ $status -ne 0 ]; then
	    error 'ERROR: Fatal error occurred ($status)'
	    exit 1
	fi
}

parse_command_line () {
  if [ $# -eq 0 ]; then
    usage
    return 1
  fi

  # See if profile document was provided
  mkdir -p $HOME/.unison
  [ -f /profile/default.prf ] && cp -rf /profile/default.prf $HOME/.unison/default.prf

  WORKSPACE_NAME=$1
  shift
  COMMAND_EXTRA_ARGS="$*"
}

usage () {
  printf "%s" "${USAGE}"
}

info() {
  printf  "${GREEN}INFO:${NC} %s\n" "${1}"
}

warn() {
  printf  "${RED}WARNING:${NC} %s\n" "${1}"
}

debug() {
  printf  "${BLUE}DEBUG:${NC} %s\n" "${1}"
}

error() {
  echo  "---------------------------------------"
  echo "!!!"
  echo "!!! ${1}"
  echo "!!!"
  echo  "---------------------------------------"
  return 1
}

stop_sync() {
  echo "Received interrupt signal. Exiting."
  exit 1
}

# See: https://sipb.mit.edu/doc/safe-shell/
set -u

# on callback, kill the last background process, which is `tail -f /dev/null` and execute the specified handler
trap 'stop_sync' SIGHUP SIGTERM SIGINT

init_logging
init_global_variables
parse_command_line "$@"
[ "$(ls -A /mnthost )" ] && EMPTY=false || EMPTY=true
if [ $EMPTY = false ]; then
    if [ INTERACTIVE ] ; then
        warn "(${CHE_MINI_PRODUCT_NAME} mount): Local folder is not empty. Are you sure?[Y/n]"
        read yn
        case $yn in
            [Yy]*) 
                break
                ;;
            [Nn]*) 
                exit
                ;;
            *) 
                info "(${CHE_MINI_PRODUCT_NAME} mount): Please answer yes or no."
                ;;
        esac
    else
        error "ERROR: Local folder is not empty. Add `ti` to run command or delete content from local folder."
    fi
    
fi
docker run --rm  -v /var/run/docker.sock:/var/run/docker.sock eclipse/che-action:${CHE_VERSION} get-ssh-data ${WORKSPACE_NAME} ${COMMAND_EXTRA_ARGS} > $HOME/env
if [ $? -ne 0 ]; then
    error "ERROR: Error when trying to get workspace data for workspace named ${WORKSPACE_NAME}"
    echo "List of workspaces are:"
    docker run --rm  -v /var/run/docker.sock:/var/run/docker.sock eclipse/che-action:${CHE_VERSION} list-workspaces ${COMMAND_EXTRA_ARGS} --sync-agent
    return 1
fi
source $HOME/env

# store private key
mkdir -p $HOME/.ssh
if [ -z "$PS1" ]; then
    INTERACTIVE=false
else
    INTERACTIVE=true
fi
echo "${SSH_PRIVATE_KEY}" > $HOME/.ssh/id_rsa
chmod 600 $HOME/.ssh/id_rsa
if [ "${CHE_SYNC_AGENT}" = "true" ]; then
    UNISON_COMMAND=${UNISON_COMMAND_AGENT}
    info "(${CHE_MINI_PRODUCT_NAME} mount): Syncing ${SSH_USER}@${SSH_IP}:${SSH_PORT}${REMOTE_SYNC_FOLDER} with workspace sync agent."
else
    UNISON_COMMAND=${UNISON_COMMAND_SSHFS}
    info "(${CHE_MINI_PRODUCT_NAME} mount): Sync agent not detected using SSHFS."
    info "(${CHE_MINI_PRODUCT_NAME} mount): Mounting ${SSH_USER}@${SSH_IP}:${REMOTE_SYNC_FOLDER} (${SSH_PORT}) with SSHFS."
    sshfs ${SSH_USER}@${SSH_IP}:${REMOTE_SYNC_FOLDER} /mntssh -p ${SSH_PORT} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no
    check_status
    info "(${CHE_MINI_PRODUCT_NAME} mount): Successfully mounted ${SSH_USER}@${SSH_IP}:${REMOTE_SYNC_FOLDER} (${SSH_PORT})"
fi    

info "(${CHE_MINI_PRODUCT_NAME} mount): Starting Initial sync... Please wait."
START_TIME=$(date +%s)
eval ${UNISON_COMMAND}
ELAPSED_TIME=$(expr $(date +%s) - $START_TIME)
info "INFO: (${CHE_MINI_PRODUCT_NAME} mount): Initial sync took $ELAPSED_TIME seconds."
info "(${CHE_MINI_PRODUCT_NAME} mount): Background sync continues every ${UNISON_REPEAT_DELAY_IN_SEC} seconds."
info "(${CHE_MINI_PRODUCT_NAME} mount): This terminal will block while the synchronization continues."
info "(${CHE_MINI_PRODUCT_NAME} mount): To stop, issue a SIGTERM or SIGINT, usually CTRL-C."
check_status
while [ 1 ]
do
    sleep ${UNISON_REPEAT_DELAY_IN_SEC}
    eval ${UNISON_COMMAND}
done
check_status
