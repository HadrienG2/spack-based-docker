FROM hgrasland/root-tests:latest-cxx17
LABEL Description="openSUSE Tumbleweed environment for Gaudi"
CMD bash

# Use my Gaudi package development branch
#
# FIXME: Move back to official Spack repo once everything is upstreamed.
#
RUN cd /opt/spack                                                              \
    && git remote add HadrienG2 https://github.com/HadrienG2/spack.git         \
    && git fetch HadrienG2                                                     \
    && git checkout gaudi-package

# The RELAX package's rolling release policy is considered naughty by Spack as
# it makes builds non-reproducible. To disable checksum verification for this
# package while keeping it for others, we'll need to jump through some hoops...
RUN spack install --only dependencies relax ^ ${ROOT_SPACK_SPEC}               \
    && spack install --no-checksum relax ^ ${ROOT_SPACK_SPEC}

# Build a spack spec for Gaudi
RUN echo "export GAUDI_SPACK_SPEC=\"gaudi@develop +tests +optional             \
                                        ^ ${ROOT_SPACK_SPEC}\"" >> ${SETUP_ENV}

# Build Gaudi and its dependencies using Spack
RUN spack build ${GAUDI_SPACK_SPEC}

# Test the Gaudi build
#
# NOTE: Some Gaudi tests do ptrace system calls, which are not allowed in
#       unprivileged docker containers because they leak too much information
#       about the host. You can allow the container to run these tests
#       by passing the "--security-opt=seccomp:unconfined" flag to docker run,
#       but for some strange reason this flag cannot be passed to docker build.
#       Therefore, we disable these tests during the docker image build.
#
RUN spack cd --build-dir ${GAUDI_SPACK_SPEC}                                   \
    && cd spack-build                                                          \
    && spack build-env gaudi+tests+optional                                    \
           ctest -j8 -E "(google_auditors\.heapchecker|event_timeout_abort)"

# Drop the build to save space in the final Docker image
#
# (This will preserve dependencies, therefore reinstalling should be quick)
#
RUN spack clean ${GAUDI_SPACK_SPEC}