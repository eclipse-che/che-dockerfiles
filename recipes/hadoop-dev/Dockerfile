# Copyright (c) 2012-2016 Codenvy, S.A. and LamdaFu, LLC
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
# Contributors:
# Codenvy, S.A.	- initial API and implementation
# LamdaFu, LLC 	- added BigTop 1.1.0 fork of ubuntu_jdk8 Dockerfile

FROM eclipse/ubuntu_jdk8
MAINTAINER https://github.com/LamdaFu/dockerfiles/issues

RUN echo "Setting up Bigtop 1.1.0"
RUN wget -O- http://archive.apache.org/dist/bigtop/bigtop-1.1.0/repos/GPG-KEY-bigtop | sudo apt-key add -
RUN sudo wget -O /etc/apt/sources.list.d/bigtop-1.1.0.list \
		http://archive.apache.org/dist/bigtop/bigtop-1.1.0/repos/trusty/bigtop.list
RUN sudo apt-get update
RUN sudo apt-get -y install hadoop-client hive pig sqoop flume 
