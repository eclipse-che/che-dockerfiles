# Copyright (c) 2012-2018 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#
# Contributors:
#   Red Hat, Inc. - initial API and implementation
#   LamdaFu, LLC 	- added BigTop 1.1.0 fork of ubuntu_jdk8 Dockerfile

FROM eclipse/ubuntu_jdk8
MAINTAINER https://github.com/LamdaFu/dockerfiles/issues

RUN echo "Setting up Bigtop 1.1.0"
RUN wget -O- http://archive.apache.org/dist/bigtop/bigtop-1.1.0/repos/GPG-KEY-bigtop | sudo apt-key add -
RUN sudo wget -O /etc/apt/sources.list.d/bigtop-1.1.0.list \
		http://archive.apache.org/dist/bigtop/bigtop-1.1.0/repos/trusty/bigtop.list
RUN sudo apt-get update
RUN sudo apt-get -y install hadoop-client hive pig sqoop flume 
