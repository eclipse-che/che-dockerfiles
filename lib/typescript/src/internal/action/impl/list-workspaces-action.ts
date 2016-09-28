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


// imports
import {org} from "../../../api/dto/che-dto"
import {ArgumentProcessor} from "../../../spi/decorator/argument-processor";
import {Workspace} from "../../../api/wsmaster/workspace/workspace";
import {AuthData} from "../../../api/wsmaster/auth/auth-data";
import {Parameter} from "../../../spi/decorator/parameter";
import {CreateWorkspaceConfig} from "../../../api/wsmaster/workspace/workspace";
import {Log} from "../../../spi/log/log";

/**
 * This class list all workspaces
 * @author Florent Benoit
 */
export class ListWorkspacesAction {

    @Parameter({names: ["-s", "--url"], description: "Defines the url to be used"})
    url : string;

    @Parameter({names: ["-u", "--user"], description: "Defines the user to be used"})
    username : string;

    @Parameter({names: ["-w", "--password"], description: "Defines the password to be used"})
    password : string;

    authData: AuthData;
    workspace: Workspace;

    constructor(args:Array<string>) {
        ArgumentProcessor.inject(this, args);

        this.authData = AuthData.parse(this.url, this.username, this.password);
        this.workspace = new Workspace(this.authData);
    }

    run() : Promise<any> {

        return this.authData.login().then(() => {
            return this.workspace.getWorkspaces()
                .then((workspaceDtos:Array<org.eclipse.che.api.workspace.shared.dto.WorkspaceDto>) => {
                    // then start it
                    Log.getLogger().info('Total workspaces:', workspaceDtos.length);
                    workspaceDtos.forEach((workspaceDto : any) => {
                        Log.getLogger().info('Workspace ', workspaceDto.getConfig().getName(), '(' + workspaceDto.getId() + ')',"\t", workspaceDto.getStatus());
                    })
                });
        });
    }

}
