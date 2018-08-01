# Copyright (c) 2012-2018 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#
# Contributors:
#   Red Hat, Inc. - initial API and implementation

FROM eclipse/stack-base:ubuntu
ENV KOTLIN_VERSION="1.2.50-eap-62" \
    KOTLIN_HOME=/usr/share/kotlin
RUN cd /tmp && \
    sudo wget "https://github.com/JetBrains/kotlin/releases/download/v${KOTLIN_VERSION}/kotlin-compiler-${KOTLIN_VERSION}.zip" && \
    sudo unzip "kotlin-compiler-${KOTLIN_VERSION}.zip" && \
    sudo mkdir "${KOTLIN_HOME}" && \
    sudo rm "/tmp/kotlinc/bin/"*.bat && \
    sudo mv "/tmp/kotlinc/bin" "/tmp/kotlinc/lib" "${KOTLIN_HOME}" && \
    sudo ln -s "${KOTLIN_HOME}/bin/"* "/usr/bin/"
