# Copyright (c) 2012-2016 Codenvy, S.A.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
# Contributors:
# Codenvy, S.A. - initial API and implementation

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
