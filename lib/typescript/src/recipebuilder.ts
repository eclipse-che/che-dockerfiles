/*
 * Copyright (c) 2016 Codenvy, S.A.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *   Codenvy, S.A. - initial API and implementation
 */


import {Log} from "./log";
/**
 * Build a default recipe.
 * @author Florent Benoit
 */
export class RecipeBuilder {

    DEFAULT_DOCKERFILE_CONTENT: string = 'FROM codenvy/ubuntu_jdk8';
    path: any;
    fs: any;

    constructor() {
        this.path = require('path');
        this.fs = require('fs');
    }


    getDockerContent() : string {

        // build path to the Dockerfile in current directory
        var dockerFilePath = this.path.resolve('./Dockerfile');

        // use synchronous API
        try {
            var stats = this.fs.statSync(dockerFilePath);
            Log.getLogger().info('Using a custom project Dockerfile \'' + dockerFilePath + '\' for the setup of the workspace.');
            var content = this.fs.readFileSync(dockerFilePath, 'utf8');
            return content;
        } catch (e) {
            // file does not exist, return default
            return this.DEFAULT_DOCKERFILE_CONTENT;
        }

    }

}
