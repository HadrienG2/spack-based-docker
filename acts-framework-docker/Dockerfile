# Configure the container's basic properties
#
# NOTE: We do not build on top of acts-tests because we rely on a different ACTS
#       versions and use different dependency build settings.
#
FROM hgrasland/root-tests:latest-cxx14
LABEL Description="openSUSE Tumbleweed with ACTSFW installed"
CMD bash

# Switch to a development branch of Spack with the ACTSFW package
#
# FIXME: Switch to upstream once this work is integrated.
#
RUN cd /opt/spack                                                              \
    && git remote add HadrienG2 https://github.com/HadrienG2/spack.git         \
    && git fetch HadrienG2                                                     \
    && git checkout HadrienG2/acts-framework

# Specify a full-featured build of ACTSFW
RUN echo "export ACTSFW_SPACK_SPEC=\"                                          \
              acts-framework@develop +dd4hep +fatras +geant4 +legacy +tgeo     \
                  ^ ${ROOT_SPACK_SPEC}\""                                      \
          >> ${SETUP_ENV}

# Install ACTSFW
RUN spack install --keep-stage ${ACTSFW_SPACK_SPEC}

# Run the framework examples
#
# FIXME: Fix currently failing examples ACTFWBFieldAccessExample,
#        ACTFWBFieldExample, ACTFWRootGeometryExample (exit code 0),
#        ACTFWRootPropagationExample (exit code 0)
#
RUN spack load ${ACTSFW_SPACK_SPEC}                                            \
    && spack load dd4hep                                                       \
    && spack cd --build-dir ${ACTSFW_SPACK_SPEC}                               \
    && ACTFWDD4hepGeometryExample -n 100                                       \
    && echo "---------------"                                                  \
    && ACTFWDD4hepPropagationExample -n 100                                    \
    && echo "---------------"                                                  \
    && ACTFWGenericGeometryExample -n 100                                      \
    && echo "---------------"                                                  \
    && ACTFWGenericPropagationExample -n 100                                   \
    && echo "---------------"                                                  \
    && ACTFWHelloWorldExample -n 100                                           \
    && echo "---------------"                                                  \
    && ACTFWParticleGunExample -n 100                                          \
    && echo "---------------"                                                  \
    && ACTFWRandomNumberExample -n 100                                         \
    && echo "---------------"                                                  \
    && ACTFWWhiteBoardExample -n 100

# Clean up Spack caches and temporary file to shrink the Docker image
RUN spack clean -a

# Discard the framework install: the goal is to provide a known-good framework
# build environment, but the framework is not terribly useful per se.
RUN spack uninstall -y ${ACTSFW_SPACK_SPEC}