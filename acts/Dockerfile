# Configure the container's basic properties
ARG CONTAINER_REPO=ghcr.io/hadrieng2
ARG ROOT_VERSION=6.30.02
FROM ${CONTAINER_REPO}/root-tests:${ROOT_VERSION}-cxx17
LABEL Description="openSUSE Tumbleweed with ACTS installed"
CMD bash
ARG ACTS_VERSION=31.2.0
ARG ACTS_BUILD_TYPE=RelWithDebInfo

# This is the variant of the ACTS package which we are going to build
#
# FIXME: Figure out a way to do automated CUDA testing.
#
ENV ACTS_SPACK_SPEC="acts@${ACTS_VERSION} build_type=${ACTS_BUILD_TYPE}        \
                                          +alignment -autodiff +benchmarks     \
                                          -cuda +dd4hep +examples +fatras      \
                                          +fatras_geant4 +geant4 +hepmc3       \
                                          +identification +integration_tests   \
                                          log_failure_threshold=WARNING +json  \
                                          +legacy -onnx +pythia8 +tgeo         \
                                          +unit_tests                          \
                         ^ boost -atomic -chrono cxxstd=17 -date_time          \
                                 -exception -graph +iostreams -locale -log     \
                                 -math +multithreaded -random -regex           \
                                 -serialization +shared -signals               \
                                 -system -thread -timer -wave                  \
                         ^ dd4hep -ddalign -ddcad -ddcond -dddigi -ddeve       \
                           -edm4hep -utilityapps                               \
                         ^ ${ROOT_SPACK_SPEC}"

# Build acts, do not install it yet
RUN spack install --add --fail-fast --until build ${ACTS_SPACK_SPEC}

# Cache the location of the ACTS build directory (it takes a while to compute)
#
# The weird regex is needed because spack recently started using hashes in build
# directory names, e.g. `spack-build-ucfdm6y`. I cannot get away with a simple
# `spack-build*` wildcard because it would match text files like
# `spack-build-out.txt`, but I can reasonably assume that Spack won't put a dot
# in their hash syntax for the foreseeable future.
#
RUN export ACTS_STAGE_DIR=`spack location --stage-dir ${ACTS_SPACK_SPEC}`      \
    && export ACTS_BUILD_DIR_NAME=`ls ${ACTS_STAGE_DIR} |                      \
                                   grep -E "^spack-build[^.]*$"`               \
    && export ACTS_BUILD_DIR="${ACTS_STAGE_DIR}/${ACTS_BUILD_DIR_NAME}"        \
    && echo "export ACTS_BUILD_DIR=${ACTS_BUILD_DIR}" >> ${SETUP_ENV}          \
    && export ACTS_SRC_DIR="${ACTS_STAGE_DIR}/spack-src"                       \
    && echo "export ACTS_SRC_DIR=${ACTS_SRC_DIR}" >> ${SETUP_ENV}

# Run the unit tests
RUN cd ${ACTS_BUILD_DIR} && spack build-env acts ctest -j$(nproc)

# Run the integration tests too (skip in Debug builds, as they are too slow)
RUN if [ "$ACTS_BUILD_TYPE" != "Debug" ]; then                                 \
        cd ${ACTS_BUILD_DIR}                                                   \
        && spack build-env acts -- cmake --build . -- integrationtests;        \
    fi

# Run the benchmarks (skip in Debug builds, as they are too slow)
RUN if [ "$ACTS_BUILD_TYPE" != "Debug" ]; then                                 \
        cd ${ACTS_BUILD_DIR}/bin                                               \
        && spack build-env acts ./ActsBenchmarkAnnulusBoundsBenchmark          \
        && echo "---------------"                                              \
        && spack build-env acts ./ActsBenchmarkAtlasStepper                    \
        && echo "---------------"                                              \
        && spack build-env acts ./ActsBenchmarkBoundaryCheck                   \
        && echo "---------------"                                              \
        && spack build-env acts ./ActsBenchmarkEigenStepper                    \
        && echo "---------------"                                              \
        && spack build-env acts ./ActsBenchmarkRayFrustumBenchmark             \
        && echo "---------------"                                              \
        && spack build-env acts ./ActsBenchmarkSolenoidField                   \
        && echo "---------------"                                              \
        && spack build-env acts ./ActsBenchmarkSurfaceIntersection;            \
    fi

# Run the examples (skip in Debug builds, as most are too slow)
RUN if [ "$ACTS_BUILD_TYPE" != "Debug" ]; then                                 \
      DD4HEP_PREFIX=`spack location --install-dir dd4hep`                      \
      && source ${DD4HEP_PREFIX}/bin/thisdd4hep.sh                             \
      && ln -s ${ACTS_BUILD_DIR} ${ACTS_SRC_DIR}/build;                        \
      cd ${ACTS_SRC_DIR}                                                       \
      && ./CI/run_examples.sh;                                                 \
    fi

# Finish installing ACTS
RUN spack install --add --fail-fast ${ACTS_SPACK_SPEC}

# Discard the ACTS build directory and the associated environment setup
RUN spack gc -y                                                                \
    && spack clean -a                                                          \
    && mv ${SETUP_ENV} ${SETUP_ENV}.old                                        \
    && grep -E --invert-match "ACTS_(BUILD|SRC)_DIR" ${SETUP_ENV}.old          \
            >> ${SETUP_ENV}                                                    \
    && rm ${SETUP_ENV}.old
