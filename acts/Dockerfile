# Configure the container's basic properties
ARG DOCKER_REPO=hgrasland
ARG ROOT_VERSION=6.16.00
FROM ${DOCKER_REPO}/root-tests:${ROOT_VERSION}-cxx17
LABEL Description="openSUSE Tumbleweed with ACTS installed"
CMD bash
ARG ACTS_BUILD_TYPE=RelWithDebInfo

# This is the variant of the ACTS package which we are going to build
#
# FIXME: Bring back +dd4hep once either of the following is true:
#        1. ROOT can be built with +opengl +x
#        2. DD4hep does not require ROOT to have OpenGL / X11 support anymore
#
# FIXME: Relax Boost version constraint once ACTS supports or overrides the new
#        Boost CMake configuration mechanism introduced by 1.70.0.
#
RUN echo "export ACTS_SPACK_SPEC=\"                                            \
                     acts-core@develop build_type=${ACTS_BUILD_TYPE} -dd4hep   \
                                       +digitization +examples +identification \
                                       +integration_tests +json +legacy        \
                                       +material +tests +tgeo                  \
                     ^ boost@1.69.0                                            \
                     ^ ${ROOT_SPACK_SPEC}\""                                   \
         >> ${SETUP_ENV}

# Build acts-core, do not install it yet
RUN spack build ${ACTS_SPACK_SPEC}

# Cache the location of the ACTS build directory (it takes a while to compute)
RUN export ACTS_STAGE_DIR=`spack location --stage-dir ${ACTS_SPACK_SPEC}`      \
    && echo "export ACTS_SOURCE_DIR=${ACTS_STAGE_DIR}/acts-core"               \
            >> ${SETUP_ENV}                                                    \
    && echo "export ACTS_BUILD_DIR=${ACTS_STAGE_DIR}/spack-build"              \
            >> ${SETUP_ENV}

# Run the unit tests
RUN cd ${ACTS_BUILD_DIR} && spack build-env acts-core ctest -j8

# Run the integration tests as well
RUN cd ${ACTS_BUILD_DIR}/Tests/Integration                                     \
    && spack build-env acts-core ./PropagationTests                            \
    && spack build-env acts-core ./SeedingTest

# Run the benchmarks as well
RUN cd ${ACTS_BUILD_DIR}/Tests/Core                                            \
    && spack build-env acts-core ./Propagator/EigenStepperBenchmark            \
    && spack build-env acts-core ./Propagator/AtlasStepperBenchmark            \
    && spack build-env acts-core ./Surfaces/BoundaryCheckBenchmark

# Finish installing ACTS
RUN cd ${ACTS_SOURCE_DIR} && spack diy --quiet ${ACTS_SPACK_SPEC}

# Discard the ACTS build directory and the associated environment setup
RUN spack clean -a                                                             \
    && mv ${SETUP_ENV} ${SETUP_ENV}.old                                        \
    && grep -E --invert-match "ACTS_(SOURCE|BUILD)_DIR" ${SETUP_ENV}.old       \
            >> ${SETUP_ENV}                                                    \
    && rm ${SETUP_ENV}.old
