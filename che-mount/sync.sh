#!/bin/sh
# Copyright (c) 2012-2016 Codenvy, S.A., Red Hat, Inc
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
            -v \${HOME}/.unison:\${HOME}/.unison 
            -v /etc/group:/etc/group:ro 
            -v /etc/passwd:/etc/passwd:ro 
            -u \$(id -u \${USER})
            -v <local-mount>/:/mnthost codenvy/che-mount <ip> <port> 
           
Usage on Mac or Windows:
  docker run --rm -it --cap-add SYS_ADMIN --device /dev/fuse
            --name che-mount 
            -v ~/.ssh:/root/.ssh
            -v <local-mount>/:/mnthost codenvy/che-mount <ip> <port>

     <local-mount>    Host directory to sync files, must end with a slash '/'
     <ip>             IP address of Che server
     <port>           Port of workspace SSH server - retrieve inside workspace
"
 UNISON_REPEAT_DELAY_IN_SEC=2
}

parse_command_line () {
  if [ $# -eq 0 ]; then
    usage
    exit
  fi
}

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

# See: https://sipb.mit.edu/doc/safe-shell/
set -u

init_logging
init_global_variables
parse_command_line "$@"

info "INFO: ECLIPSE CHE: Mounting user@$1:/projects with SSHFS"
sshfs user@$1:/projects /mntssh -p $2
status=$?
if [ $status -ne 0 ]; then
    error "ERROR: Fatal error occurred ($status)"
    exit 1
fi
info "INFO: ECLIPSE CHE: Successfully mounted user@$1:/projects"
info "INFO: ECLIPSE CHE: Intial sync...Please wait."
unison /mntssh /mnthost -batch -fat -silent -auto -prefer=newer -log=false > /dev/null 2>&1
status=$?
if [ $status -ne 0 ]; then
    error "ERROR: Fatal error occurred ($status)"
    exit 1
fi
info "INFO: ECLIPSE CHE: Background sync continues every ${UNISON_REPEAT_DELAY_IN_SEC} seconds."

# -repeat=watch doesn't work because SSHFS doesn't support inotify and 
# unison-fsmonitor rely on inotify
unison /mntssh /mnthost -batch -retry 10 -fat -silent -copyonconflict -auto -prefer=newer -repeat=${UNISON_REPEAT_DELAY_IN_SEC} -log=false  > /dev/null 2>&1
status=$?
if [ $status -ne 0 ]; then
    error "ERROR: Fatal error occurred ($status)"
    exit 1
fi
