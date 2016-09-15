# docker-ubuntu

A container for testing builds

## Build process

The build process is a matter of:

 1. Make changes
 2. Push changes to remote repo
 3. Tag release and push tags to remote repo
 4. Run `make container`

This results in a Docker image built and tagged with:

 1. The git ref of the build
 2. The git tag of the build

## Caveats

 * Only the first git tag is used to tag the Docker image
