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
            -v /etc/group:/etc/group:ro 
            -v /etc/passwd:/etc/passwd:ro 
            -v <path-to-sync-profile>:/profile
            -u \$(id -u \${USER})
            -v <local-mount>/:/mnthost codenvy/che-mount <ip> <port> 
           
Usage on Mac or Windows:
  docker run --rm -it --cap-add SYS_ADMIN --device /dev/fuse
            --name che-mount 
            -v <path-to-sync-profile>:/profile
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
    return 1
  fi

  # See if profile document was provided
  mkdir -p $HOME/.unison
  cp -rf /profile/default.prf $HOME/.unison/default.prf 
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
  echo  "---------------------------------------"
  error "!!!"
  error "!!! ${1}"
  error "!!!"
  echo  "---------------------------------------"
  return 1
}

stop_sync() {
  echo "Recived interrupt signal. Exiting."
  exit 1
}

# See: https://sipb.mit.edu/doc/safe-shell/
set -u

# on callback, kill the last background process, which is `tail -f /dev/null` and execute the specified handler
trap 'stop_sync' SIGHUP SIGTERM SIGINT

init_logging
init_global_variables
parse_command_line "$@"

info "INFO: (che mount): Mounting user@$1:/projects with SSHFS"
sshfs user@$1:/projects /mntssh -p $2
status=$?
if [ $status -ne 0 ]; then
    error "ERROR: Fatal error occurred ($status)"
    exit 1
fi
info "INFO: (che mount): Successfully mounted user@$1:/projects"
info "INFO: (che mount): Intial sync...Please wait."
unison /mntssh /mnthost -batch -fat -silent -auto -prefer=newer -log=false > /dev/null 2>&1
status=$?
if [ $status -ne 0 ]; then
    error "ERROR: Fatal error occurred ($status)"
    exit 1
fi
info "INFO: (che mount): Background sync continues every ${UNISON_REPEAT_DELAY_IN_SEC} seconds."
info "INFO: (che mount): This terminal will block while the synchronization continues."
info "INFO: (che mount): To stop, issue a SIGTERM, usually CTRL-C."

# run application
unison /mntssh /mnthost -batch -retry 10 -fat -silent -copyonconflict -auto -prefer=newer -repeat=${UNISON_REPEAT_DELAY_IN_SEC} -log=false > /dev/null 2>&1
#PID=$!
#echo "hi"
# See: http://veithen.github.io/2014/11/16/sigterm-propagation.html
#wait $PID
#wait $PID
#EXIT_STATUS=$?

# wait forever
#while true
#do
#  tail -f /dev/null & wait ${!}
#done
