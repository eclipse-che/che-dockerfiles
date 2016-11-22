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
            [-e SYNC_AGENT=<sync-agent>]
            -v <local-mount>/:/mnthost 
            eclipse/che-mount <workspace-id|workspace-name> 
            	[--url=<url>]
            	[--user=<user>]
            	[--password=<password>]
           
Usage on Mac or Windows:
  docker run --rm -it --cap-add SYS_ADMIN --device /dev/fuse
            --name che-mount 
            -v <path-to-sync-profile>:/profile
            [-e SSH_USER=<SSH_USER>]
            [-e SSH_IP=<IP>]
            [-e SSH_PORT=<SSH_PORT>]
            [-e SYNC_AGENT=<sync-agent>]
            -v <local-mount>/:/mnthost 
            eclipse/che-mount <workspace-id|workspace-name> 
            	[--url=<url>]
            	[--user=<user>]
            	[--password=<password>]

     <local-mount>    Host directory to sync files, must end with a slash '/'
     <url>            Defines the url to be used
     <user>           Username used to authenticate with server if required
     <password>       Password used to authenticate with server if required
     <sync-agent>     True/False value to use workspace machine unison sync agent(Default 'false')
     <workspace-id|workspace-name> ID or Name of the workspace or namespace:workspace-name
"
 UNISON_REPEAT_DELAY_IN_SEC=2
 WORKSPACE_NAME=
 COMMAND_EXTRA_ARGS=
}

parse_command_line () {
  if [ $# -eq 0 ]; then
    usage
    return 1
  fi

  # See if profile document was provided
  mkdir -p $HOME/.unison
  cp -rf /profile/default.prf $HOME/.unison/default.prf

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
    warn "(che mount): Local folder is not empty. This could overwrite information on remote workspace. Are you sure you want to continue?"
    read yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) info "(che mount): Please answer yes or no.";;
    esac
fi
docker run --rm  -v /var/run/docker.sock:/var/run/docker.sock eclipse/che-action:${CHE_VERSION} get-ssh-data ${WORKSPACE_NAME} ${COMMAND_EXTRA_ARGS} > $HOME/env
if [ $? -ne 0 ]; then
    error "ERROR: Error when trying to get workspace data for workspace named ${WORKSPACE_NAME}"
    echo "List of workspaces are:"
    docker run --rm  -v /var/run/docker.sock:/var/run/docker.sock eclipse/che-action:${CHE_VERSION} list-workspaces ${COMMAND_EXTRA_ARGS}
    return 1
fi
source $HOME/env

# store private key
mkdir -p $HOME/.ssh
echo "${SSH_PRIVATE_KEY}" > $HOME/.ssh/id_rsa
if [ $3 = true ]; then
else
    info "INFO: (che mount): Mounting ${SSH_USER}@${SSH_IP}:/projects (${SSH_PORT}) with SSHFS"
    sshfs ${SSH_USER}@${SSH_IP}:/projects /mntssh -p ${SSH_PORT} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no
    status=$?
    if [ $status -ne 0 ]; then
        error "ERROR: Fatal error occurred ($status)"
        exit 1
    fi
else
    info "(che mount): Syncing ${SSH_USER}@${SSH_IP}:${SSH_PORT}/projects with workspace sync agent."
fi


# run application
if [ $3 = true ]; then
	info "(che mount): Background sync continues every ${UNISON_REPEAT_DELAY_IN_SEC} seconds."
    info "(che mount): This terminal will block while the synchronization continues."
    info "(che mount): To stop, issue a SIGTERM or SIGINT, usually CTRL-C."
    info "(che mount): Initial Unison sync time using Unison in workspace machine:"
    START_TIME=$(date +%s)
    unison /mnthost ssh://${SSH_USER}@${SSH_IP}:${SSH_PORT}//../../projects/ -batch -retry 10 \
      -fat -silent -copyonconflict -auto -prefer=newer -log=false > /dev/null 2>&1
    ELAPSED_TIME=$(expr $(date +%s) - $START_TIME)
    #ELAPSED_TIME=$(expr $ELAPSED_TIME / 60)
    info "(che mount): Initial Unison sync took $ELAPSED_TIME seconds."
    unison /mnthost ssh://user@$1:$2//../../projects/ -batch -retry 10 \
      -fat -silent -copyonconflict -auto -prefer=newer -repeat=${UNISON_REPEAT_DELAY_IN_SEC} -log=false > /dev/null 2>&1
    status=$?
	if [ $status -ne 0 ]; then
	    error "ERROR: Fatal error occurred ($status)"
	    exit 1
	fi
else
	info "INFO: (che mount): Successfully mounted ${SSH_USER}@${SSH_IP}:/projects (${SSH_PORT})"
    info "(che mount): Initial sync...Please wait."
    info "(che mount): Initial Unison sync time using SSHFS:"
    START_TIME=$(date +%s)
    unison /mntssh /mnthost -batch -fat -silent -auto -prefer=newer -log=false > /dev/null 2>&1
    status=$?
	if [ $status -ne 0 ]; then
	    error "ERROR: Fatal error occurred ($status)"
	    exit 1
	fi
    ELAPSED_TIME=$(expr $(date +%s) - $START_TIME)
    info "INFO: (che mount): Initial Unison sync took $ELAPSED_TIME seconds."
    #ELAPSED_TIME=$(expr $ELAPSED_TIME / 60)
    info "(che mount): Background sync continues every ${UNISON_REPEAT_DELAY_IN_SEC} seconds."
    info "(che mount): This terminal will block while the synchronization continues."
    info "(che mount): To stop, issue a SIGTERM or SIGINT, usually CTRL-C."
    unison /mntssh /mnthost -batch -retry 10 -fat -silent -copyonconflict -auto -prefer=newer -repeat=${UNISON_REPEAT_DELAY_IN_SEC} -log=false > /dev/null 2>&1
fi
