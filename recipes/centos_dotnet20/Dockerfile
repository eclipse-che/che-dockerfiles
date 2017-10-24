# Copyright (c) 2012-2017 Red Hat, Inc
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html

FROM registry.centos.org/che-stacks/centos-stack-base:latest

RUN sudo yum -y update && \
    sudo yum -y install centos-release-dotnet && \
    sudo yum -y install rh-dotnet20 && \
    sudo yum clean all && \
    sudo ln -s /opt/rh/rh-dotnet20/root/usr/lib64/dotnet/sdk/2.0.0/Sdks/Microsoft.NET.Sdk/tools/netcoreapp1.0 /opt/rh/rh-dotnet20/root/usr/lib64/dotnet/sdk/2.0.0/Sdks/Microsoft.NET.Sdk/tools/net46

ENV PATH=/opt/rh/rh-dotnet20/root/usr/bin:/opt/rh/rh-dotnet20/root/usr/sbin${PATH:+:${PATH}}
ENV CPATH=/opt/rh/rh-dotnet20/root/usr/include${CPATH:+:${CPATH}}
ENV LD_LIBRARY_PATH=/opt/rh/rh-dotnet20/root/usr/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
ENV MANPATH=/opt/rh/rh-dotnet20/root/usr/share/man:${MANPATH:-}
ENV PKG_CONFIG_PATH=/opt/rh/rh-dotnet20/root/usr/lib64/pkgconfig${PKG_CONFIG_PATH:+:${PKG_CONFIG_PATH}}
ENV PYTHONPATH=/opt/rh/rh-dotnet20/root${PYTHONPATH:+:${PYTHONPATH}}
ENV XDG_DATA_DIRS=/opt/rh/rh-dotnet20/root/usr/share:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}
ENV DOTNET_CLI_TELEMETRY_OPTOUT=true

RUN sudo yum -y install rh-nodejs6 && \
    sudo yum clean all && \
    sudo ln -s /opt/rh/rh-nodejs6/root/usr/bin/node /usr/local/bin/nodejs 
ENV PATH=/opt/rh/rh-nodejs6/root/usr/bin${PATH:+:${PATH}}
ENV LD_LIBRARY_PATH=/opt/rh/rh-nodejs6/root/usr/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
ENV PYTHONPATH=/opt/rh/rh-nodejs6/root/usr/lib/python2.7/site-packages${PYTHONPATH:+:${PYTHONPATH}}
ENV MANPATH=/opt/rh/rh-nodejs6/root/usr/share/man:$MANPATH

EXPOSE 5000
