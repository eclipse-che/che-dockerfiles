# Copyright (c) 2012-2016 Codenvy, S.A.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
# Contributors:
# Codenvy, S.A. - initial API and implementation

FROM codenvy/php

RUN composer global require "laravel/installer" && \
    sudo sed -i '$ d' /home/user/.bashrc

ENV PATH /home/user/.composer/vendor/bin:$PATH

