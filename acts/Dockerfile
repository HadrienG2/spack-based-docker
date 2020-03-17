# Configure the container's basic properties
ARG DOCKER_REPO=hgrasland
ARG ROOT_VERSION=6.18.04
FROM ${DOCKER_REPO}/root-tests:${ROOT_VERSION}-cxx17
LABEL Description="openSUSE Tumbleweed with ACTS installed"
CMD bash
ARG ACTS_VERSION=0.17.00
ARG ACTS_BUILD_TYPE=RelWithDebInfo

# This is the variant of the ACTS package which we are going to build
RUN echo "export ACTS_SPACK_SPEC=\"                                            \
                     acts-core@${ACTS_VERSION} build_type=${ACTS_BUILD_TYPE}   \
                                               +benchmarks +dd4hep             \
                                               +digitization +examples +fatras \
                                               +identification                 \
                                               +integration_tests +json        \
                                               +legacy +tests +tgeo            \
                         ^ boost -atomic -chrono cxxstd=17 -date_time          \
                                 -exception -filesystem -graph -iostreams      \
                                 -locale -log -math +multithreaded             \
                                 +program_options -random -regex               \
                                 -serialization +shared -signals -system +test \
                                 -thread -timer -wave                          \
                         ^ ${ROOT_SPACK_SPEC}                                  \
         \"" >> ${SETUP_ENV}

# Build acts-core, do not install it yet
RUN spack install --until build ${ACTS_SPACK_SPEC}

# Cache the location of the ACTS build directory (it takes a while to compute)
RUN export ACTS_STAGE_DIR=`spack location --stage-dir ${ACTS_SPACK_SPEC}`      \
    && export ACTS_BUILD_DIR="${ACTS_STAGE_DIR}/spack-build"                   \
    && echo "export ACTS_BUILD_DIR=${ACTS_BUILD_DIR}" >> ${SETUP_ENV}

# Run the unit tests
RUN cd ${ACTS_BUILD_DIR} && spack build-env acts-core ctest -j8

# Run the integration tests as well
RUN cd ${ACTS_BUILD_DIR}                                                       \
    && spack build-env acts-core -- cmake --build . -- integrationtests

# Run the benchmarks as well
RUN cd ${ACTS_BUILD_DIR}/Tests/Benchmarks                                      \
    && spack build-env acts-core ./ActsBenchmarkAtlasStepper                   \
    && spack build-env acts-core ./ActsBenchmarkBoundaryCheck                  \
    && spack build-env acts-core ./ActsBenchmarkEigenStepper                   \
    && spack build-env acts-core ./ActsBenchmarkSolenoidField                  \
    && spack build-env acts-core ./ActsBenchmarkSurfaceIntersection

# Finish installing ACTS
RUN spack install ${ACTS_SPACK_SPEC}

# Discard the ACTS build directory and the associated environment setup
RUN spack gc -y                                                                \
    && spack clean -a                                                          \
    && mv ${SETUP_ENV} ${SETUP_ENV}.old                                        \
    && grep -E --invert-match "ACTS_BUILD_DIR" ${SETUP_ENV}.old                \
            >> ${SETUP_ENV}                                                    \
    && rm ${SETUP_ENV}.old
