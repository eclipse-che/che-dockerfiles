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
import {CheFileStructWorkspace} from './chefile-struct/che-file-struct';
import {CheFileStruct} from './chefile-struct/che-file-struct';
import {CheFileServerTypeStruct} from "./chefile-struct/che-file-struct";
import {resolve} from "url";
import {Websocket} from "../../spi/websocket/websocket";
import {AuthData} from "../../api/wsmaster/auth/auth-data";
import {Workspace} from "../../api/wsmaster/workspace/workspace";
import {Message} from "../../spi/decorator/message";
import {I18n} from "../../spi/i18n/i18n";
import {RemoteIp} from "../../spi/docker/remoteip";
import {Log} from "../../spi/log/log";
import {CreateWorkspaceConfig} from "../../api/wsmaster/workspace/workspace";
import {Project} from "../../api/wsmaster/project/project";
import {RecipeBuilder} from "../../spi/docker/recipebuilder";
import {ContainerVersion} from "../../spi/docker/container-version";
import {DefaultHttpJsonRequest} from "../../spi/http/default-http-json-request";
import {HttpJsonRequest} from "../../spi/http/default-http-json-request";
import {HttpJsonResponse} from "../../spi/http/default-http-json-request";
import {UUID} from "../../utils/uuid";
import {WorkspaceDto} from "../../api/wsmaster/workspace/dto/workspacedto";
import {MachineServiceClientImpl} from "../../api/wsmaster/machine/machine-service-client";
import {CheFileStructWorkspaceCommand} from "./chefile-struct/che-file-struct";
import {CheFileStructWorkspaceCommandImpl} from "./chefile-struct/che-file-struct";
import {CheFileStructWorkspaceLoadingAction} from "./chefile-struct/che-file-struct";
import {ArgumentProcessor} from "../../spi/decorator/argument-processor";
import {Parameter} from "../../spi/decorator/parameter";
import {ProductName} from "../../utils/product-name";
import {SSHGenerator} from "../../spi/docker/ssh-generator";

/**
 * Entrypoint for the Chefile handling in a directory.
 * It can either generate or reuse an existing Chefile and then boot Che.
 * @author Florent Benoit
 */
export class CheDir {

  @Parameter({names: ["--verbose"], description: "Display in verbose mode."})
  isVerbose : boolean = false;

  // Try 30s to ping a che server when booting it
  times: number = 30;

  // gloabl var
  waitDone = false;

  chefileStruct: CheFileStruct;
  chefileStructWorkspace: CheFileStructWorkspace;

  // requirements
  path = require('path');
  http = require('http');
  fs = require('fs');
  vm = require('vm');
  readline = require('readline');
  exec = require('child_process').exec;

  // init folder/files variables
  currentFolder: string = this.path.resolve('./');
  folderName: any;
  cheFile : any;
  dotCheFolder : any;
  confFolder : any;
  workspacesFolder : any;
  chePropertiesFile : any;
  dotCheIdFile : any;
  dotCheSshPrivateKeyFile : any;
  dotCheSshPublicKeyFile : any;
  instanceId: string;

  mode;
  args : Array<string>;

  cheLauncherImageName : string;

  websocket: Websocket;
  authData: AuthData;
  workspace: Workspace;

  @Message('internal/dir/che-dir-constant')
  i18n : I18n;

  constructor(args) {
    this.args = ArgumentProcessor.inject(this, args);


    this.currentFolder = this.path.resolve(args[0]);
    this.folderName = this.path.basename(this.currentFolder);
    this.cheFile = this.path.resolve(this.currentFolder, 'Chefile');
    this.dotCheFolder = this.path.resolve(this.currentFolder, '.che');
    this.dotCheIdFile = this.path.resolve(this.dotCheFolder, 'id');
    this.dotCheSshPrivateKeyFile = this.path.resolve(this.dotCheFolder, 'ssh-key.private');
    this.dotCheSshPublicKeyFile = this.path.resolve(this.dotCheFolder, 'ssh-key.public');
    this.confFolder = this.path.resolve(this.dotCheFolder, 'conf');
    this.workspacesFolder = this.path.resolve(this.dotCheFolder, 'workspaces');
    this.chePropertiesFile = this.path.resolve(this.confFolder, 'che.properties');

    this.initDefault();

    this.websocket = new Websocket();

    this.authData = new AuthData();

    // che launcher image name
    if (process.env.CHE_LAUNCHER_IMAGE_NAME) {
      this.cheLauncherImageName = process.env.CHE_LAUNCHER_IMAGE_NAME
    } else {
      this.cheLauncherImageName = 'codenvy/che-launcher';
    }
  }



  initDefault() {
    this.chefileStruct = new CheFileStruct();
    this.chefileStruct.server.ip = new RemoteIp().getIp();
    this.chefileStruct.server.port = 8080;
    this.chefileStruct.server.type =  'local';

    this.chefileStructWorkspace = new CheFileStructWorkspace();
    this.chefileStructWorkspace.name = 'local';
    this.chefileStructWorkspace.ram = 2048;

    try {
      this.fs.statSync(this.dotCheIdFile);
      // we have a file
      this.instanceId = this.fs.readFileSync(this.dotCheIdFile).toString();
    } catch (e) {
      this.instanceId = UUID.build();
      this.writeInstanceId();
    }

    /*Object.keys(process.env).forEach((key) => {
      Log.getLogger().debug('Env variable', key, process.env[key]);
    });*/

    if (process.env.CHE_HOST_IP) {
      this.chefileStruct.server.properties['CHE_HOST_IP'] = process.env.CHE_HOST_IP;
    }



  }



  startsWith(value:string, searchString: string) : boolean {
    return value.substr(0, searchString.length) === searchString;
  }


  parseArgument() : Promise<string> {
    return new Promise<string>( (resolve, reject) => {
      let invalidCommand : string = 'only init, up, down, ssh and status commands are supported.';
      if (this.args.length == 0) {
        reject(invalidCommand);
      } else if ('init' === this.args[1]
                 || 'up' === this.args[1]
                 || 'destroy' === this.args[1]
                 || 'down' === this.args[1]
                 || 'ssh' === this.args[1]
                 || 'status' === this.args[1]) {
        // return method found based on arguments
        resolve(this.args[1]);
      } else {
        reject('Invalid arguments ' + this.args +': ' + invalidCommand);
      }
    });

  }

  run() : Promise<string> {
    Log.context = ProductName.getShortDisplayName() + '(dir)';

    // call the method analyzed from the argument
    return this.parseArgument().then((methodName) => {
      return this[methodName]();
    })


  }

  parse() {

    try {
      this.fs.statSync(this.cheFile);
      // we have a file
    } catch (e) {
      Log.getLogger().debug('No chefile defined, use default settings');
      return;
    }

    // load the chefile script if defined
    var script_code = this.fs.readFileSync(this.cheFile).toString();

    // strip the lines that are beginning with # as it may be comments
    script_code = script_code.replace(/#[^\n]*/g, '');

    // create sandboxed object
    var sandbox = { "che": this.chefileStruct,  "workspace": this.chefileStructWorkspace, "console": console};

    let options = {
      filename : this.cheFile,
      displayErrors : true
    };

    try {
      this.vm.runInNewContext(script_code, sandbox, options);
    } catch (error) {
      if (error.stack) {
        // search correct line
        let splitLines = error.stack.split('\n');
        var found : boolean = false;
        var i : number = 0;
        while (!found && i < splitLines.length) {
          let currentStackLine = splitLines[i];
          if (currentStackLine.indexOf(this.cheFile) != -1) {
            // found matching line
            found = true;
            let splitColumns = currentStackLine.split(':');
            // check line number only or both line+column number
            if (splitColumns.length == 3) {
              // line and column number
              let lineNumber = splitColumns[1];
              let colNumber = splitColumns[2];
              throw new Error('Error while parsing the file \'' + this.cheFile + '\' at line ' + lineNumber + ' and column ' + colNumber + '. The error is :' + error.message);
            } else if (splitColumns.length == 2) {
              // only line number
              let lineNumber = splitColumns[1];
              throw new Error('Error while parsing the file \'' + this.cheFile + '\' at line ' + lineNumber + '. The error is :' + error.message);
            }
          }
          i++;
        }
        }
      // not able to parse error
      throw error;
    }

    this.cleanupArrays();

    Log.getLogger().debug('Che file parsing object is ', JSON.stringify(this.chefileStruct));
    Log.getLogger().debug('Che workspace parsing object is ', JSON.stringify(this.chefileStructWorkspace));

    this.authData.port = this.chefileStruct.server.port;

  }


  /**
   * Cleanup arrays by removing extra elements
   */
  cleanupArrays() {
    // now, cleanup invalid commands
    for (let i : number = this.chefileStructWorkspace.commands.length - 1; i >= 0 ; i--) {
      // no name, drop it
      if (!this.chefileStructWorkspace.commands[i].name) {
        this.chefileStructWorkspace.commands.splice(i, 1);
      }
    }
    // now, cleanup invalid commands
    for (let i : number = this.chefileStructWorkspace.postload.actions.length - 1; i >= 0 ; i--) {
        // no name, drop it
        if (!this.chefileStructWorkspace.postload.actions[i].command && !this.chefileStructWorkspace.postload.actions[i].script) {
          this.chefileStructWorkspace.postload.actions.splice(i, 1);
        }
    }

  }

  /**
   * Check if directory has been initialized or not
   * @return true if initialization has been done
   */
  isInitialized() : Promise<boolean> {
    return new Promise<boolean>((resolve) => {
      try {
        this.fs.statSync(this.chePropertiesFile);
        resolve(true);
      } catch (e) {
        resolve(false);
      }
    });

  }


  /**
   * Write a default chefile
   */
  writeDefaultChefile() {


    //
    this.chefileStructWorkspace.commands[0].name = "my-first-command";
    this.chefileStructWorkspace.commands[0].commandLine = "echo this is my first command && read";
    this.chefileStructWorkspace.postload.actions[0].command = "my-first-command";
    this.chefileStructWorkspace.postload.actions[1].script = "echo 'this is my custom command' && while true; do echo $(date); sleep 1; done";

    // remove empty values
    this.cleanupArrays();

    // create content to write
    let content = '';

    // work on a copy
    let che : CheFileStruct =  JSON.parse(JSON.stringify(this.chefileStruct));

    // make flat the che object
    let flatChe = this.flatJson('che', che);
    flatChe.forEach((value, key) => {
      Log.getLogger().debug( 'the value is ' + value.toString() + ' for key' + key);
      content += key + '=' + value.toString() + '\n';
    });

    // make flat the workspace object
    let flatWorkspace = this.flatJson('workspace', this.chefileStructWorkspace);
    flatWorkspace.forEach((value, key) => {
      Log.getLogger().debug( 'the flatWorkspace value is ' + value.toString() + ' for key' + key);
      content += key + '=' + value.toString() + '\n';
    });

    // write content of this.che object
    this.fs.writeFileSync(this.cheFile, content);
    Log.getLogger().info('Generating default', this.cheFile);


    try {
      this.fs.chownSync(this.cheFile, 1000, 1000);
    } catch (error) {
      Log.getLogger().debug("Unable to chown che file", this.cheFile);
    }


  }


  init() : Promise<any> {
    return this.isInitialized().then((isInitialized) => {
      if (isInitialized) {
        Log.getLogger().warn('Che already initialized');
      } else {
        // needs to create folders
        this.initCheFolders();
        this.setupConfigFile();

        // write a default chefile if there is none
        try {
          this.fs.statSync(this.cheFile);
          Log.getLogger().debug('Chefile is present at ', this.cheFile);
        } catch (e) {
          // write default
          Log.getLogger().debug('Write a default Chefile at ', this.cheFile);
          this.writeDefaultChefile();
        }
        Log.getLogger().info('Adding', this.dotCheFolder, 'directory');
        return true;
      }

    });

  }

  status() : Promise<any> {
    return this.isInitialized().then((isInitialized) => {
      if (!isInitialized) {
        return Promise.reject('This directory has not been initialized. So, status is not available.');
      }

      return new Promise<string>((resolve, reject) => {
        this.parse();
        resolve('parsed');
      }).then(() => {
        return this.checkCheIsRunning();
      }).then((isRunning) => {
        if (!isRunning) {
          return Promise.reject('No Eclipse Che Instance Running.');
        }

        // check workspace exists
        this.workspace = new Workspace(this.authData);
        return this.workspace.existsWorkspace(':' + this.chefileStructWorkspace.name);
      }).then((workspaceDto : WorkspaceDto) => {
        // found it
        if (!workspaceDto) {
          return Promise.reject('Eclipse Che is running ' + this.buildLocalCheURL() + ' but workspace (' + this.chefileStructWorkspace.name + ') has not been found');
        }

        // search IDE url link
        let ideUrl : string = 'N/A';
        workspaceDto.getContent().links.forEach((link) => {
          if ('ide url' === link.rel) {
            ideUrl = link.href;
          }
        });
        Log.getLogger().info(this.i18n.get('status.workspace.name', this.chefileStructWorkspace.name));
        Log.getLogger().info(this.i18n.get('status.workspace.url', ideUrl));
        Log.getLogger().info(this.i18n.get('status.instance.id', this.instanceId));
        return Promise.resolve(true);
      });
    });

  }


  /**
   * Search a che instance and stop it it it's currently running
   */
  down() : Promise<void> {

    // call init if not initialized and then call up
    return this.isInitialized().then((isInitialized) => {
      if (!isInitialized) {
        throw new Error('Unable to stop current instance as this directory has not been initialized.')
      }
    }).then(() => {

      return new Promise<string>((resolve, reject) => {
        this.parse();

        resolve();
      }).then(() => {
        Log.getLogger().info(this.i18n.get('down.search'));

        // Try to connect to Eclipse Che instance
        return this.checkCheIsRunning();
      }).then((isRunning) => {
        if (!isRunning) {
          return Promise.reject(this.i18n.get('down.not-running'));
        }
        Log.getLogger().info(this.i18n.get('down.found', this.buildLocalCheURL()));
        Log.getLogger().info(this.i18n.get('down.stopping'));

        // call docker stop on the docker launcher
        return this.cheStop();
      }).then(() => {
        Log.getLogger().info(this.i18n.get('down.stopped'));
      });
    });
  }



  /**
   * Search a che instance and destroy workspace and then stop
   */
  destroy() : Promise<void> {

    // check if directory has been initialized or not
    return this.isInitialized().then((isInitialized) => {
      if (!isInitialized) {
        throw new Error('Unable to stop current instance as this directory has not been initialized.')
      }
    }).then(() => {

      return new Promise<string>((resolve, reject) => {
        this.parse();

        resolve();
      }).then(() => {
        Log.getLogger().info(this.i18n.get('down.search'));

        // Try to connect to Eclipse Che instance
        return this.checkCheIsRunning();
      }).then((isRunning) => {
        if (!isRunning) {
          return Promise.reject(this.i18n.get('down.not-running'));
        }
        Log.getLogger().info(this.i18n.get('down.found', this.buildLocalCheURL()));
        this.workspace = new Workspace(this.authData);
        // now, check if there is a workspace
        return this.workspace.existsWorkspace(':' + this.chefileStructWorkspace.name);
      }).then((workspaceDto : WorkspaceDto) => {
        // exists ?
        if (!workspaceDto) {
          // workspace is not existing
          Log.getLogger().warn(this.i18n.get('destroy.workspace-not-existing', this.chefileStructWorkspace.name));
          // call docker stop on the docker launcher
          Log.getLogger().info(this.i18n.get('down.stopping'));
          return this.cheStop();
        } else {
          // first stop and then delete workspace
            Log.getLogger().info(this.i18n.get('destroy.destroying-workspace', this.chefileStructWorkspace.name));
            return this.workspace.stopWorkspace(workspaceDto.getId()).then(() => {
              return this.workspace.deleteWorkspace(workspaceDto.getId());
            }).then(() => {
              Log.getLogger().info(this.i18n.get('destroy.destroyed-workspace', this.chefileStructWorkspace.name));
              // then stop server
              Log.getLogger().info(this.i18n.get('down.stopping'));
              return this.cheStop();
            });
        }
      }).then(() => {
        Log.getLogger().info(this.i18n.get('down.stopped'));
      });
    });
  }


  up() : Promise<string> {
  let start : number = Date.now();
    // call init if not initialized and then call up
    return this.isInitialized().then((isInitialized) => {
      if (!isInitialized) {
        return this.init();
      }
    }).then(() => {


      var ideUrl : string;

      var needToSetupProject: boolean = true;
      var userWorkspaceDto: WorkspaceDto;
      var workspaceHasBeenCreated : boolean = false;
      return new Promise<string>((resolve, reject) => {
        this.parse();

        // test if conf is existing
        try {
          var statsPropertiesFile = this.fs.statSync(this.chePropertiesFile);
        } catch (e) {
          reject(this.i18n.get('up.notconfigured'));
        }
        resolve('parsed');
      }).then(() => {
        return this.checkCheIsNotRunning();
      }).then((isNotRunning) => {
        return new Promise<boolean>((resolve, reject) => {
          if (isNotRunning) {
            resolve(true);
          } else {
            reject(this.i18n.get('up.existinginstance'));
          }
        });
      }).then((checkOk) => {
        Log.getLogger().info(this.i18n.get('up.starting'));
        // needs to invoke docker run
        return this.cheBoot();
      }).then((data) => {
        // loop to check startup (during 30seconds)
        return this.loopWaitChePing();
      }).then((value) => {
        Log.getLogger().info(this.i18n.get('up.running', this.buildLocalCheURL()));
        // check workspace exists
        this.workspace = new Workspace(this.authData);
        return this.workspace.existsWorkspace(':' + this.chefileStructWorkspace.name);
      }).then((workspaceDto) => {
        // found it
        if (!workspaceDto) {
          // workspace is not existing
          // now create the workspace
          let createWorkspaceConfig:CreateWorkspaceConfig = new CreateWorkspaceConfig();

          let recipe: string = new RecipeBuilder(this.currentFolder).getRecipe(this.chefileStructWorkspace);
          Log.getLogger().debug("Using workspace recipe", recipe);
          createWorkspaceConfig.machineConfigSource = recipe;
          createWorkspaceConfig.commands = this.chefileStructWorkspace.commands;
          createWorkspaceConfig.name = this.chefileStructWorkspace.name;
          createWorkspaceConfig.ram = this.chefileStructWorkspace.ram;
          Log.getLogger().info(this.i18n.get('up.workspace-created'));
          workspaceHasBeenCreated = true;
          return this.workspace.createWorkspace(createWorkspaceConfig)
        } else {
          // do not create it, just return current one
          Log.getLogger().info(this.i18n.get('up.workspace-previous-start'));
          needToSetupProject = false;
          return workspaceDto;
        }
      }).then((workspaceDto) => {
        Log.getLogger().info(this.i18n.get('up.workspace-booting'));
        return this.workspace.startWorkspace(workspaceDto.getId(), this.isVerbose);
      }).then((workspaceDto) => {
        return this.workspace.getWorkspace(workspaceDto.getId())
      }).then((workspaceDto) => {
        userWorkspaceDto = workspaceDto;
        // search IDE url link
        workspaceDto.getContent().links.forEach((link) => {
          if ('ide url' === link.rel) {
            ideUrl = link.href;
          }
        });
      }).then(() => {
          return this.setupSSHKeys(userWorkspaceDto);
      }).then(() => {
        if (needToSetupProject) {
         Log.getLogger().info(this.i18n.get('up.updating-project'));
         var project:Project = new Project(userWorkspaceDto);
         // update created project to blank
         return this.estimateAndUpdateProject(project, this.chefileStructWorkspace.projects[0].type);
         } else {
          Promise.resolve('existing project');
        }
      }).then(() => {
        return this.executeCommandsFromCurrentWorkspace(userWorkspaceDto);
      }).then(() => {
        Log.getLogger().info(this.i18n.get('up.workspace-booted'));
      }).then(() => {
        let end : number = Date.now();
        Log.getLogger().debug("time =", end - start);
        Log.getLogger().info(this.i18n.get('up.workspace-connect-to', ideUrl));
        return ideUrl;
      });

    });
  }

setupSSHKeys(workspaceDto: WorkspaceDto) : Promise<any> {

   let privateKey : string;
   let publicKey : string;
  // check if we have keys locally or not ?
   try {
      this.fs.statSync(this.dotCheSshPrivateKeyFile);
      // we have the file
      privateKey = this.fs.readFileSync(this.dotCheSshPrivateKeyFile).toString();
      publicKey = this.fs.readFileSync(this.dotCheSshPublicKeyFile).toString();
      Log.getLogger().info('Using existing ssh key');     
   } catch (e) {
      // no file, need to generate key
      Log.getLogger().info('Generating ssh key');
      let map : Map<string, string> = new SSHGenerator().generateKey();

      // store locally the private and public keys
      privateKey = map.get('private');
      publicKey = map.get('public');
      this.fs.writeFileSync(this.dotCheSshPrivateKeyFile, privateKey,  { mode: 0o600 });
      this.fs.writeFileSync(this.dotCheSshPublicKeyFile, publicKey);

     try {
       this.fs.chownSync(this.dotCheSshPrivateKeyFile, 1000, 1000);
     } catch (error) {
       Log.getLogger().debug("Unable to chown ssh key private file", this.dotCheSshPrivateKeyFile);
     }

   }

    // ok we have the public key, now storing it
    // get dev machine
    let machineId : string = workspaceDto.getContent().runtime.devMachine.id;

    let machineServiceClient:MachineServiceClientImpl = new MachineServiceClientImpl(this.workspace, this.authData);

    let uuid:string = UUID.build();
    let channel:string = 'process:output:' + uuid;

    let customCommand:CheFileStructWorkspaceCommand = new CheFileStructWorkspaceCommandImpl();
    customCommand.commandLine = 'mkdir $HOME/.ssh && echo "' + publicKey + '"> $HOME/.ssh/authorized_keys';
    customCommand.name = 'setup ssh';
    customCommand.type = 'custom';
    
   // store in workspace the public key
   return machineServiceClient.executeCommand(workspaceDto, machineId, customCommand, channel, false);
 
}


  ssh() : Promise<any> {
    return this.isInitialized().then((isInitialized) => {
      if (!isInitialized) {
        return Promise.reject('This directory has not been initialized. So, ssh is not available.');
      }

      return new Promise<string>((resolve, reject) => {
        this.parse();
        resolve('parsed');
      }).then(() => {
        return this.checkCheIsRunning();
      }).then((isRunning) => {
        if (!isRunning) {
          return Promise.reject('No Eclipse Che Instance Running.');
        }

        // check workspace exists
        this.workspace = new Workspace(this.authData);
        return this.workspace.existsWorkspace(':' + this.chefileStructWorkspace.name);
      }).then((workspaceDto : WorkspaceDto) => {
        // found it
        if (!workspaceDto) {
          return Promise.reject('Eclipse Che is running ' + this.buildLocalCheURL() + ' but workspace (' + this.chefileStructWorkspace.name + ') has not been found');
        }


        let port: string = workspaceDto.getContent().runtime.devMachine.runtime.servers["22/tcp"].address.split(":")[1];
        var spawn = require('child_process').spawn;

        let username : string = "user@" + this.chefileStruct.server.ip;

        var p = spawn("docker", ["run", "-v", this.dotCheSshPrivateKeyFile + ":/tmp/ssh.key", "-ti", "codenvy/alpine_jdk8", "ssh", "-o", "UserKnownHostsFile=/dev/null", "-o", "StrictHostKeyChecking=no", username, "-p", port, "-i", "/tmp/ssh.key"], {
          stdio: 'inherit'
        });

        p.on('error', (err) => {
          Log.getLogger().error(err);
        });

        p.on('exit', () => {
          Log.getLogger().info('Ending ssh connection');
        });
        return Promise.resolve("ok");
      })
    });
  }




estimateAndUpdateProject(project: Project, projectType: string) : Promise<any> {
  Log.getLogger().debug('estimateAndUpdateProject with projectType', projectType);

  var projectTypeToUse: string;
  // try to estimate
  return project.estimateType(this.folderName, projectType).then((content) => {
    if (!content.matched) {
      Log.getLogger().warn('Wanted to configure project as ' + projectType + ' but server replied that this project type is not possible. Keep Blank');  
      projectTypeToUse = 'blank'; 
    } else {
      projectTypeToUse = projectType;
    }
    // matched = true, then continue
    return true;
  }).then(() => {
    // estimate done, update
    return project.updateType(this.folderName, projectTypeToUse);
  })
  
}




  executeCommandsFromCurrentWorkspace(workspaceDto : WorkspaceDto) : Promise<any> {
    // get dev machine
    let machineId : string = workspaceDto.getContent().runtime.devMachine.id;


    let promises : Array<Promise<any>> = new Array<Promise<any>>();
    let workspaceCommands : Array<any> = workspaceDto.getContent().config.commands;
    let machineServiceClient:MachineServiceClientImpl = new MachineServiceClientImpl(this.workspace, this.authData);

    if (this.chefileStructWorkspace.postload.actions && this.chefileStructWorkspace.postload.actions.length > 0) {
      Log.getLogger().info(this.i18n.get("executeCommandsFromCurrentWorkspace.executing"));
    }

    this.chefileStructWorkspace.postload.actions.forEach((postLoadingCommand: CheFileStructWorkspaceLoadingAction) => {
      let uuid:string = UUID.build();
      let channel:string = 'process:output:' + uuid;

      if (postLoadingCommand.command) {
        workspaceCommands.forEach((workspaceCommand) => {
          if (postLoadingCommand.command === workspaceCommand.name) {
            let customCommand:CheFileStructWorkspaceCommand = new CheFileStructWorkspaceCommandImpl();
            customCommand.commandLine = workspaceCommand.commandLine;
            customCommand.name = workspaceCommand.name;
            customCommand.type = workspaceCommand.type;
            customCommand.attributes = workspaceCommand.attributes;
            Log.getLogger().debug('Executing post-loading workspace command \'' + postLoadingCommand.command + '\'.');
            promises.push(machineServiceClient.executeCommand(workspaceDto, machineId, customCommand, channel, false));
          }
        });
      } else if (postLoadingCommand.script) {
        let customCommand:CheFileStructWorkspaceCommand = new CheFileStructWorkspaceCommandImpl();
        customCommand.commandLine = postLoadingCommand.script;
        customCommand.name = 'custom postloading command';
        Log.getLogger().debug('Executing post-loading script \'' + postLoadingCommand.script + '\'.');
        promises.push(machineServiceClient.executeCommand(workspaceDto, machineId, customCommand, channel, false));
      }


    });

    return Promise.all(promises);
  }




  buildLocalCheURL() : string {
    return 'http://' + this.chefileStruct.server.ip + ':' + this.chefileStruct.server.port;
  }

  initCheFolders() {

    // create .che folder
    try {
      this.fs.mkdirSync(this.dotCheFolder, 0o744);
    } catch (e) {
      // already exist
    }

    // write instance id
    this.writeInstanceId();

    // create .che/workspaces folder
    try {
      this.fs.mkdirSync(this.workspacesFolder, 0o744);
    } catch (e) {
      // already exist
    }

    // create .che/conf folder

    try {
      this.fs.mkdirSync(this.confFolder, 0o744);
    } catch (e) {
      // already exist
    }


    // copy configuration file

    try {
      var stats = this.fs.statSync(this.chePropertiesFile);
    } catch (e) {
      // file does not exist, copy it
      this.fs.writeFileSync(this.chePropertiesFile, this.fs.readFileSync(this.path.resolve(__dirname, 'che.properties')));
    }

  }

  writeInstanceId() {
    try {
      this.fs.writeFileSync(this.dotCheIdFile, this.instanceId);
    } catch (e) {
      // already exist
    }
  }

  setupConfigFile() {
    // need to setup che.properties file with workspaces folder

    // update che.user.workspaces.storage
    this.updateConfFile('che.user.workspaces.storage', this.workspacesFolder);

    // update extra volumes
    this.updateConfFile('machine.server.extra.volume', this.currentFolder + ':/projects/' + this.folderName + ";/var/run/docker.sock:/var/run/docker.sock");

  }

  updateConfFile(propertyName, propertyValue) {

    var content = '';
    var foundLine = false;
    this.fs.readFileSync(this.chePropertiesFile).toString().split('\n').forEach((line) => {

      var updatedLine;



      if (this.startsWith(line, propertyName)) {
        foundLine = true;
        updatedLine = propertyName + '=' + propertyValue + '\n';
      } else {
        updatedLine = line  + '\n';
      }

      content += updatedLine;
    });

    // add property if not present
    if (!foundLine) {
      content += propertyName + '=' + propertyValue + '\n';
    }

    this.fs.writeFileSync(this.chePropertiesFile, content);

  }


  getCheServerContainerName() : string {
    return 'che-server-' + this.instanceId;
  }

  cheBoot() : Promise<any> {

    let promise : Promise<any> = new Promise<any>((resolve, reject) => {
      let containerVersion : string = new ContainerVersion().getVersion();

      // create command line to execute
      var commandLine: string = 'docker run --rm';

      // add extra properties
      for(var property in this.chefileStruct.server.properties){
        let envProperty : string = ' --env ' + property + '=\"' + this.chefileStruct.server.properties[property] + '\"';
        commandLine += envProperty;
      }

      // continue with own properties
      commandLine +=
          ' -v /var/run/docker.sock:/var/run/docker.sock' +
          ' -e CHE_PORT=' + this.chefileStruct.server.port +
          ' -e CHE_DATA_FOLDER=' + this.workspacesFolder +
          ' -e CHE_CONF_FOLDER=' + this.confFolder +
          ' -e CHE_SERVER_CONTAINER_NAME=' + this.getCheServerContainerName() +
          ' ' + this.cheLauncherImageName + ':' + containerVersion + ' start';

      Log.getLogger().debug('Executing command line', commandLine);


      var child = this.exec(commandLine , (error, stdout, stderr) => {
            if (error) {
              Log.getLogger().error('Error when starting che with che-launcher: ' + error.toString() + '. exit code was ' + error.code);
              Log.getLogger().error('Startup traces were on stdout:\n', stdout.toString());
              Log.getLogger().error('Startup traces were on stderr:\n', stderr.toString());
            } else {
              resolve({
                childProcess: child,
                stdout: stdout,
                stderr: stderr
              });
            }
          });

      child.stdout.on('data', (data) => {
        Log.getLogger().debug(data.toString());
      });


      child.on('exit', (exitCode) => {
        if (exitCode == 0) {
          resolve('success');
        } else {
          reject('process has exited');
        }

      });

    });

    return promise;

  }



  cheStop() : Promise<any> {

    let promise : Promise<any> = new Promise<any>((resolve, reject) => {
      let containerVersion : string = new ContainerVersion().getVersion();

      var commandLine: string = 'docker run --rm' +
          ' -v /var/run/docker.sock:/var/run/docker.sock' +
          ' -e CHE_PORT=' + this.chefileStruct.server.port +
          ' -e CHE_DATA_FOLDER=' + this.workspacesFolder +
          ' -e CHE_CONF_FOLDER=' + this.confFolder +
          ' -e CHE_SERVER_CONTAINER_NAME=' + this.getCheServerContainerName() +
          ' ' + this.cheLauncherImageName + ':' + containerVersion + ' stop';

      Log.getLogger().debug('Executing command line', commandLine);


      var child = this.exec(commandLine , (error, stdout, stderr) => {
        if (error) {
          Log.getLogger().error('Error when stopping che with che-launcher: ' + error.toString() + '. exit code was ' + error.code);
          Log.getLogger().error('Stopping traces were on stdout:\n', stdout.toString());
          Log.getLogger().error('Stopping traces were on stderr:\n', stderr.toString());
        } else {
          resolve({
            childProcess: child,
            stdout: stdout,
            stderr: stderr
          });
        }
      });

      child.stdout.on('data', (data) => {
        Log.getLogger().debug(data.toString());
      });


      child.on('exit', (exitCode) => {
        if (exitCode == 0) {
          resolve('success');
        } else {
          reject('process has exited');
        }

      });

    });

    return promise;

  }


  checkCheIsNotRunning() : Promise <boolean> {
    var jsonRequest:HttpJsonRequest = new DefaultHttpJsonRequest(this.authData, '/api/workspace', 200);
    return jsonRequest.request().then((jsonResponse:HttpJsonResponse) => {
      return false;
    }, (error) => {
      // find error when connecting so probaly not running
      return true;
    });
  }


  checkCheIsRunning() : Promise<boolean> {
    var jsonRequest:HttpJsonRequest = new DefaultHttpJsonRequest(this.authData, '/api/workspace', 200);
    return jsonRequest.request().then((jsonResponse:HttpJsonResponse) => {
      return true;
    }, (error) => {
      // find error when connecting so probaly not running
      return false;
    });
  }


  pingCheAction() : void {
    var options = {
      hostname: this.chefileStruct.server.ip,
      port: this.chefileStruct.server.port,
      path: '/api/workspace',
      method: 'GET',
      headers: {
        'Accept': 'application/json, text/plain, */*',
        'Content-Type': 'application/json;charset=UTF-8'
      }
    };

    var req = this.http.request(options, (res) => {
      res.on('data', (body) => {
        Log.getLogger().debug('got rest status code =', res.statusCode);
        if (res.statusCode === 200 && !this.waitDone) {
          Log.getLogger().debug('got 200 status, stop waiting');
          this.waitDone = true;
        }
      });
    });
    req.on('error', (e) => {
      Log.getLogger().debug('Got error when waiting che boot: ' + e.message);
    });
    req.end();

  }


  /**
   * Loop to send ping action each second and then try to see if we need to wait or not again
   */
  loopWaitChePing() : Promise<boolean> {
    return new Promise<boolean>((resolve, reject) => {
      var loop = () => {
        this.pingCheAction();
        if (this.waitDone) {
          resolve(true);
        } else {
          Log.getLogger().debug('pinging che was not ready, continue ', this.times, ' times.');
          this.times--;
          if (this.times === 0) {
            reject('Timeout for pinging Eclipse Che has been reached. Please check logs.');
          } else {
            // loop again
            setTimeout(loop, 1000);
          }
        }
      };
      process.nextTick(loop);
    });
  }





  /**
   * Flatten a JSON object and return a map of string with key and value
   * @param prefix the prefix to use in order to flatten given object instance
   * @param data the JSON object
   * @returns {Map<any, any><string, string>} the flatten map
   */
  flatJson(prefix, data) : Map<string, string> {
    var map = new Map<string, string>();

    this.recurseFlatten(map, data, prefix);
    return map;
  }


  /**
   * Recursive method to iterate on elements of a JSON object.
   * @param map the map containing the key being the property name and the value the JSON element value
   * @param jsonData the data to parse
   * @param prop the nme of the property being analyzed
     */
  recurseFlatten(map : Map<string, string>, jsonData: any, prop: string) : void {

    if (Object(jsonData) !== jsonData) {
      if (this.isNumber(jsonData)) {
        map.set(prop, jsonData);
      } else {
        map.set(prop, "\"" + jsonData + "\"");
      }
    } else if (Array.isArray(jsonData)) {
      let arr : Array<any> = jsonData;
      let l: number = arr.length;
      if (l == 0) {
        map.set(prop, '[]');
      } else {
        for(var i : number =0 ; i<l; i++) {
          this.recurseFlatten(map, arr[i], prop + "[" + i + "]");
        }
      }
    } else {
      var isEmpty = true;
      for (var p in jsonData) {
        isEmpty = false;
        this.recurseFlatten(map, jsonData[p], prop ? prop + "." + p : p);
      }
      /*if (isEmpty && prop) {
        map.set(prop, '{}');
      }*/
    }
  }

  isNumber(n) {
    return !isNaN(parseFloat(n)) && isFinite(n);
  }


}
