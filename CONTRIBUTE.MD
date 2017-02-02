# PRs for new stacks

## Naming conventions for repositories

Folder names in `/recipes` are repository name. So, if you want your image to be eclipse/my-image, create `/recipes/my-image` directory with Dockerfile in it.

## Naming conventions for tags

By default all stack images have `:latest` tag. If your repo should have several tags, create a subdirectory in your repo directory, say, `/recipes/my-image/mytag` with a Dockerfile in it.

Your repo will be built as `eclipse/my-image:mytag`.

`:latest` tag will be added by default, if your repo directory does not have any sub-dirs.

# Repositories to issue PRs

Once a PR is issued in `che-dockerfiles` repository, another PR has to be created - this time to add your stack to Stack Library in Eclipse Che. Such a PR is optional.

Just having your repo built in an Eclipse DockerHub account does not mean the stack will show up in Stack Library. Take a look [Stacks in Che](https://github.com/eclipse/che/blob/master/ide/che-core-ide-stacks/src/main/resources/stacks.json)