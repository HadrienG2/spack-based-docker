# A Dockerfile for using the ROOT HEP framework

This Dockerfile is intended as a way to quickly get started with [ROOT](
https://root.cern.ch/).

You can build a container image from it using Docker (`docker build .`), and
non-Docker builders like buildah should work as well as long as you re-enable
layer caching if your builder disables them by default (`--layers` option for
buildah). This is anyway something you will want when debugging builds.
