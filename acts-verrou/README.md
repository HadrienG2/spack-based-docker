# A Dockerfile for doing Verrou studies on ACTS

This Dockerfile provides a development environment suitable for performing
[Verrou](https://github.com/edf-hpc/verrou)-assisted numerical studies on the
[ACTS](https://acts.web.cern.ch/ACTS/) codebase.

You can build a Docker image from it using "docker build .", or you can use the
pre-built hgrasland/acts-verrou-tests image on the public Docker Hub.

It should also build fine with non-Docker builders like buildah, as long as you
re-enable layer caching if your builder disables them by default (`--layers`
option for buildah). This is anyway something you want when debugging builds.
