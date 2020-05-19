# Configure the container's basic properties
ARG DOCKER_REPO=hgrasland
ARG ROOT_VERSION=6.20.04
FROM ${DOCKER_REPO}/root-tests:${ROOT_VERSION}-cxx17
LABEL Description="openSUSE Tumbleweed with ACTS installed"
CMD bash
ARG ACTS_VERSION=0.24.00
ARG ACTS_BUILD_TYPE=RelWithDebInfo

# This is the variant of the ACTS package which we are going to build
#
# FIXME: xerces-c cxxstd must be forced to "11" because it's "default" by
#        by default, Geant4 asks for "11", and Spack isn't smart enough to
#        figure out that these two constraints are compatible.
#
ENV ACTS_SPACK_SPEC="acts@${ACTS_VERSION} build_type=${ACTS_BUILD_TYPE}        \
                                          +benchmarks +dd4hep +digitization    \
                                          +examples +fatras +geant4  +hepmc3   \
                                          +identification +integration_tests   \
                                          +json +legacy +pythia8 +tgeo         \
                                          +unit_tests                          \
                         ^ boost -atomic -chrono cxxstd=17 -date_time          \
                                 -exception +filesystem -graph -iostreams      \
                                 -locale -log -math +multithreaded             \
                                 +program_options -random -regex               \
                                 -serialization +shared -signals -system +test \
                                 -thread -timer -wave                          \
                         ^ ${ROOT_SPACK_SPEC}                                  \
                         ^ xerces-c cxxstd=11"

# Build acts, do not install it yet
RUN spack install --until build ${ACTS_SPACK_SPEC}

# Cache the location of the ACTS build directory (it takes a while to compute)
RUN export ACTS_STAGE_DIR=`spack location --stage-dir ${ACTS_SPACK_SPEC}`      \
    && export ACTS_BUILD_DIR="${ACTS_STAGE_DIR}/spack-build"                   \
    && echo "export ACTS_BUILD_DIR=${ACTS_BUILD_DIR}" >> ${SETUP_ENV}          \
    && export ACTS_SRC_DIR="${ACTS_STAGE_DIR}/spack-src"                       \
    && echo "export ACTS_SRC_DIR=${ACTS_SRC_DIR}" >> ${SETUP_ENV}

# Run the unit tests
RUN cd ${ACTS_BUILD_DIR} && spack build-env acts ctest -j8

# Run the integration tests too (skip in Debug builds, as they are too slow)
RUN if [ "$ACTS_BUILD_TYPE" != "Debug" ]; then                                 \
        cd ${ACTS_BUILD_DIR}                                                   \
        && spack build-env acts -- cmake --build . -- integrationtests;        \
    fi

# Run the benchmarks (skip in Debug builds, as they are too slow)
RUN if [ "$ACTS_BUILD_TYPE" != "Debug" ]; then                                 \
        cd ${ACTS_BUILD_DIR}/bin                                               \
        && spack build-env acts ./ActsBenchmarkAtlasStepper                    \
        && echo "---------------"                                              \
        && spack build-env acts ./ActsBenchmarkBoundaryCheck                   \
        && echo "---------------"                                              \
        && spack build-env acts ./ActsBenchmarkEigenStepper                    \
        && echo "---------------"                                              \
        && spack build-env acts ./ActsBenchmarkSolenoidField                   \
        && echo "---------------"                                              \
        && spack build-env acts ./ActsBenchmarkSurfaceIntersection;            \
    fi

# Run the examples (skip in Debug builds, as many of them are too slow)
#
# TODO: May want to experiment in Debug builds and selectively whitelist
#       simple examples like the Geometry ones.
#
# FIXME: Cannot test ActsExampleMagneticField, ActsExampleMagneticFieldAccess,
#        ActsExampleMaterialMappingDD4hep, ActsExampleMaterialMappingGeneric,
#        ActsExampleReadCsvGeneric, ActsRecTruthTracks, ActsRecVertexReader and
#        ActsSimFatrasTGeo as no input data file is provided and it's unclear
#        how to get one.
#
# FIXME: Cannot auto-test ActsExampleGeometryTGeo, ActsExampleHepMC3 and
#        ActsExamplePropagationTGeo as they do not reliably exit a nonzero
#        status code upon major failure (e.g. input not found).
#
# FIXME: The PayloadDetector-based examples ActsExamplePropagationPayload and
#        ActsSimFatrasPayload crash with a bad_any_cast, see
#        https://github.com/acts-project/acts/issues/164 .
#
# FIXME: The ActsSimGeantinoRecording example currently crashes due to
#        https://github.com/acts-project/acts/issues/204 and
#        https://github.com/acts-project/acts/issues/205 . Once that's fixed, it
#        can run, but will need to be forced into single-threaded mode with -j1
#        until https://github.com/acts-project/acts/issues/207 is resolved.
#
RUN if [ "$ACTS_BUILD_TYPE" != "Debug" ]; then                                 \
        export DD4HEP_PREFIX=`spack location --install-dir dd4hep`             \
        && source ${DD4HEP_PREFIX}/bin/thisdd4hep.sh                           \
        && cd ${ACTS_SRC_DIR}/Examples                                         \
        && spack build-env acts                                                \
                 ${ACTS_BUILD_DIR}/bin/ActsExampleGeometryAligned -n 100       \
        && echo "---------------"                                              \
        && spack build-env acts                                                \
                 ${ACTS_BUILD_DIR}/bin/ActsExampleGeometryDD4hep -n 100        \
        && echo "---------------"                                              \
        && spack build-env acts                                                \
                 ${ACTS_BUILD_DIR}/bin/ActsExampleGeometryEmpty -n 100         \
        && echo "---------------"                                              \
        && spack build-env acts                                                \
                 ${ACTS_BUILD_DIR}/bin/ActsExampleGeometryGeneric -n 100       \
        && echo "---------------"                                              \
        && spack build-env acts                                                \
                 ${ACTS_BUILD_DIR}/bin/ActsExampleGeometryPayload -n 100       \
        && echo "---------------"                                              \
        && spack build-env acts                                                \
                 ${ACTS_BUILD_DIR}/bin/ActsExampleHelloWorld -n 100            \
        && echo "---------------"                                              \
        && spack build-env acts                                                \
           ${ACTS_BUILD_DIR}/bin/ActsExampleMaterialValidationDD4hep -n 100    \
        && echo "---------------"                                              \
        && spack build-env acts                                                \
           ${ACTS_BUILD_DIR}/bin/ActsExampleMaterialValidationGeneric -n 100   \
        && echo "---------------"                                              \
        && spack build-env acts                                                \
                 ${ACTS_BUILD_DIR}/bin/ActsExamplePropagationAligned -n 100    \
        && echo "---------------"                                              \
        && spack build-env acts                                                \
                 ${ACTS_BUILD_DIR}/bin/ActsExamplePropagationDD4hep -n 100     \
        && echo "---------------"                                              \
        && spack build-env acts                                                \
                 ${ACTS_BUILD_DIR}/bin/ActsExamplePropagationEmpty -n 100      \
        && echo "---------------"                                              \
        && spack build-env acts                                                \
                 ${ACTS_BUILD_DIR}/bin/ActsExamplePropagationGeneric -n 100    \
        && echo "---------------"                                              \
        && spack build-env acts                                                \
                 ${ACTS_BUILD_DIR}/bin/ActsGenParticleGun -n 100               \
        && echo "---------------"                                              \
        && spack build-env acts                                                \
                 ${ACTS_BUILD_DIR}/bin/ActsGenPythia8 -n 100                   \
        && echo "---------------"                                              \
        && spack build-env acts                                                \
                 ${ACTS_BUILD_DIR}/bin/ActsRecVertexFinder -n 100              \
        && echo "---------------"                                              \
        && spack build-env acts                                                \
                 ${ACTS_BUILD_DIR}/bin/ActsRecVertexFitter -n 100              \
        && echo "---------------"                                              \
        && spack build-env acts                                                \
                 ${ACTS_BUILD_DIR}/bin/ActsRecVertexWriter -n 100              \
        && echo "---------------"                                              \
        && spack build-env acts                                                \
                 ${ACTS_BUILD_DIR}/bin/ActsSimFatrasAligned -n 100             \
        && echo "---------------"                                              \
        && spack build-env acts                                                \
                 ${ACTS_BUILD_DIR}/bin/ActsSimFatrasDD4hep -n 100              \
        && echo "---------------"                                              \
        && spack build-env acts                                                \
                 ${ACTS_BUILD_DIR}/bin/ActsSimFatrasGeneric -n 100;            \
    fi

# Finish installing ACTS
RUN spack install ${ACTS_SPACK_SPEC}

# Discard the ACTS build directory and the associated environment setup
RUN spack gc -y                                                                \
    && spack clean -a                                                          \
    && mv ${SETUP_ENV} ${SETUP_ENV}.old                                        \
    && grep -E --invert-match "ACTS_BUILD_DIR" ${SETUP_ENV}.old                \
            >> ${SETUP_ENV}                                                    \
    && rm ${SETUP_ENV}.old
