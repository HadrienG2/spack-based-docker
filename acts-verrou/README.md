# A Dockerfile for doing Verrou studies on ACTS

This Dockerfile provides a development environment suitable for performing
[Verrou](https://github.com/edf-hpc/verrou)-assisted numerical studies on the
[ACTS](https://acts.web.cern.ch/ACTS/) codebase.

You can build a container image from it using Docker (`docker build .`), and
non-Docker builders like buildah should work as well as long as you re-enable
layer caching if your builder disables them by default (`--layers` option for
buildah). This is anyway something you will want when debugging builds.
