# Configure the container's basic properties
ARG DOCKER_REPO=hgrasland
ARG ROOT_VERSION=6.22.00
FROM ${DOCKER_REPO}/root-tests:${ROOT_VERSION}-cxx17
LABEL Description="openSUSE Tumbleweed with ACTS installed"
CMD bash
ARG ACTS_VERSION=1.1.0
ARG ACTS_BUILD_TYPE=RelWithDebInfo

# This is the variant of the ACTS package which we are going to build
#
# FIXME: xerces-c cxxstd must be forced to "11" because it's "default" by
#        by default, Geant4 asks for "11", and Spack isn't smart enough to
#        figure out that these two constraints are compatible.
#
# FIXME: Figure out a way to do automated CUDA testing.
#
ENV ACTS_SPACK_SPEC="acts@${ACTS_VERSION} build_type=${ACTS_BUILD_TYPE}        \
                                          +benchmarks -cuda +dd4hep            \
                                          +digitization +examples +fatras      \
                                          +geant4 +hepmc3 +identification      \
                                          +integration_tests +json +legacy     \
                                          +pythia8 +tgeo +unit_tests           \
                         ^ boost -atomic -chrono cxxstd=17 -date_time          \
                                 -exception +filesystem -graph -iostreams      \
                                 -locale -log -math +multithreaded             \
                                 +program_options -random -regex               \
                                 -serialization +shared -signals -system +test \
                                 -thread -timer -wave                          \
                         ^ ${ROOT_SPACK_SPEC}                                  \
                         ^ xerces-c cxxstd=11"

# Build acts, do not install it yet
RUN spack install --fail-fast --until build ${ACTS_SPACK_SPEC}

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

# Run the examples (skip some in Debug builds, as they are too slow)
#
# FIXME: Cannot test ActsExampleGeantinoRecordingGdml, ActsExampleMagneticField,
#        ActsExampleMagneticFieldAccess, ActsExampleMaterialMappingDD4hep,
#        ActsExampleMaterialMappingGeneric, ActsExampleReadCsvGeneric,
#        ActsExampleCKFTracks and ActsExampleTruthTracks as no input data file
#        is provided and it's unclear how to get one.
#
# FIXME: Cannot auto-test ActsExampleAdaptiveMultiVertexFinder,
#        ActsExampleFatrasAligned, ActsExampleFatrasDD4hep,
#        ActsExampleFatrasGeneric, ActsExampleFatrasTGeo,
#        ActsExampleGeometryTGeo, ActsExampleHepMC3, ActsExamplePropagationTGeo
#        and ActsExampleVertexFitter as they do not reliably exit a nonzero
#        status code upon major failure (e.g. input not found).
#
# FIXME: The PayloadDetector-based examples ActsExamplePropagationPayload and
#        ActsExampleFatrasPayload crash with a bad_any_cast, see
#        https://github.com/acts-project/acts/issues/164 .
#
# FIXME: ActsExampleGeantinoRecording must currently be forced into
#        single-threaded, see https://github.com/acts-project/acts/issues/207 .
#
# FIXME: ActsExamplePropagationEmpty fails for unknown reasons, reaching an
#        infinite step count.
#
# TODO: Test ActsExampleVertexFinderReader, ActsTutorialVertexFinder,
#       ActsExampleMaterialValidationTGeo, ActsExampleMaterialMappingTGeo
#
RUN DD4HEP_PREFIX=`spack location --install-dir dd4hep`                        \
    && source ${DD4HEP_PREFIX}/bin/thisdd4hep.sh                               \
    && cd ${ACTS_SRC_DIR}/Examples                                             \
    && run_example() {                                                         \
           spack build-env --dirty acts ${ACTS_BUILD_DIR}/bin/$* -n 100;       \
       }                                                                       \
    && run_example ActsExampleGenParticleGun                                   \
    && echo "---------------"                                                  \
    && run_example ActsExampleGeometryAligned                                  \
    && echo "---------------"                                                  \
    && run_example ActsExampleGeometryDD4hep                                   \
    && echo "---------------"                                                  \
    && run_example ActsExampleGeometryEmpty                                    \
    && echo "---------------"                                                  \
    && run_example ActsExampleGeometryGeneric                                  \
    && echo "---------------"                                                  \
    && run_example ActsExampleGeometryPayload                                  \
    && echo "---------------"                                                  \
    && run_example ActsExampleHelloWorld                                       \
    && if [ "$ACTS_BUILD_TYPE" != "Debug" ]; then                              \
        echo "---------------"                                                 \
        && run_example ActsExampleGeantinoRecordingDD4hep -j1                  \
        && echo "---------------"                                              \
        && run_example ActsExampleIterativeVertexFinder                        \
        && echo "---------------"                                              \
        && run_example ActsExampleMaterialValidationDD4hep                     \
        && echo "---------------"                                              \
        && run_example ActsExampleMaterialValidationGeneric                    \
        && echo "---------------"                                              \
        && run_example ActsExamplePropagationAligned                           \
        && echo "---------------"                                              \
        && run_example ActsExamplePropagationDD4hep                            \
        && echo "---------------"                                              \
        && run_example ActsExamplePropagationGeneric                           \
        && echo "---------------"                                              \
        && run_example ActsExamplePythia8;                                     \
    fi

# Finish installing ACTS
RUN spack install --fail-fast ${ACTS_SPACK_SPEC}

# Discard the ACTS build directory and the associated environment setup
RUN spack gc -y                                                                \
    && spack clean -a                                                          \
    && mv ${SETUP_ENV} ${SETUP_ENV}.old                                        \
    && grep -E --invert-match "ACTS_(BUILD|SRC)_DIR" ${SETUP_ENV}.old          \
            >> ${SETUP_ENV}                                                    \
    && rm ${SETUP_ENV}.old
