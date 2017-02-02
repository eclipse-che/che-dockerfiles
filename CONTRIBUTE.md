# PRs for new stacks

## Naming conventions for repositories

Folder names in `/recipes` are repository name. So, if you want your image to be eclipse/my-image, create `/recipes/my-image` directory with Dockerfile in it.

## Naming conventions for tags

By default all stack images have `:latest` tag. If your repo should have several tags, create a subdirectory in your repo directory, say, `/recipes/my-image/mytag` with a Dockerfile in it.

Your repo will be built as `eclipse/my-image:mytag`.

`:latest` tag will be added by default, if your repo directory does not have any sub-dirs.

## Base Images

We recommend that you inherit from `eclipse/stack-base:ubuntu` or `eclipse/stack-base:debian` in your images. These base images have all runtime dependencies for workspace agent and some helpful utilities.

## Entrypoint and CMD

We start sshd in the `ENTRYPOINT` and our CMD is `tail -f /dev/null`. If you inherit from `eclipse/stack-base` and do not need to launch any services as the container starts, there is no need to override ENTRYPOINT or CMD.

If you override CMD, make sure it is a non-terminating command, otherwise your container will be stopped juast after CMD is executed.

# Repositories to issue PRs

Once a PR is issued in `che-dockerfiles` repository, another PR has to be created - this time to add your stack to Stack Library in Eclipse Che. Such a PR is optional.

Just having your repo built in an Eclipse DockerHub account does not mean the stack will show up in Stack Library. Take a look [Stacks in Che](https://github.com/eclipse/che/blob/master/ide/che-core-ide-stacks/src/main/resources/stacks.json)