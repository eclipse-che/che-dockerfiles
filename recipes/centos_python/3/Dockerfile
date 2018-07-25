# Copyright (c) 2012-2018 Red Hat, Inc.
# This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v2.0
# which is available at http://www.eclipse.org/legal/epl-2.0.html
#
# SPDX-License-Identifier: EPL-2.0
#
# Contributors:
#   Red Hat, Inc. - initial API and implementation

FROM registry.centos.org/che-stacks/centos-stack-base

MAINTAINER Dharmit Shah <dshah@redhat.com>

RUN sudo yum -y update && \
    sudo yum -y install centos-release-scl && \
    sudo yum -y install rh-python35 && \
    sudo yum clean all
