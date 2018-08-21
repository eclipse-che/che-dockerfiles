#!/bin/bash
#
# Copyright (c) 2016 Samsung Electronics Co., Ltd.
# This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v2.0
# which is available at http://www.eclipse.org/legal/epl-2.0.html
#
# SPDX-License-Identifier: EPL-2.0
#
# Contributors:
#   Red Hat, Inc. - Initial implementation
#   Samsung Electronics Co., Ltd. - Initial implementation
#

# $1 - username
# $2 - password
# $3 - from
# $4 - host
# $5 - to
# $6 - port

USERNAME="$1"
PASSWORD="$2"
FROM="$3"
HOST="$4"
TO="$5"
PORT="$6"

sshpass -p $PASSWORD rsync --archive --update --recursive --delete --rsh="ssh -p $PORT -o StrictHostKeyChecking=no -l $USERNAME" $FROM $USERNAME@$HOST:$TO
