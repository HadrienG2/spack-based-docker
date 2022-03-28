# A Dockerfile for using the Verrou patch to Valgrind

This Dockerfile is intended as a way to quickly get started with
[Verrou](https://github.com/edf-hpc/verrou).

You can build a Docker image from it using "docker build .", or you can use the
pre-built hgrasland/verrou-tests image on the public Docker Hub.

It should also build fine with non-Docker builders like buildah, as long as you
re-enable layer caching if your builder disables them by default (`--layers`
option for buildah). This is anyway something you want when debugging builds.
