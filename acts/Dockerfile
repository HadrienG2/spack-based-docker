# Configure the container's basic properties
ARG DOCKER_REPO=hgrasland
ARG ROOT_VERSION=6.20.04
FROM ${DOCKER_REPO}/root-tests:${ROOT_VERSION}-cxx17
LABEL Description="openSUSE Tumbleweed with ACTS installed"
CMD bash
ARG ACTS_VERSION=0.23.00
ARG ACTS_BUILD_TYPE=RelWithDebInfo

# This is the variant of the ACTS package which we are going to build
#
# FIXME: xerces-c cxxstd must be forced to "11" because it's "default" by
#        by default, Geant4 asks for "11", and Spack isn't smart enough to
#        figure out that these two constraints are compatible.
#
# FIXME: dd4hep is disabled because enabling it triggers a link error caused by
#        what looks like a CMake dependency spaghetti. I'm not touching that.
#
ENV ACTS_SPACK_SPEC="acts@${ACTS_VERSION} build_type=${ACTS_BUILD_TYPE}        \
                                          +benchmarks -dd4hep +digitization    \
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
    && echo "export ACTS_BUILD_DIR=${ACTS_BUILD_DIR}" >> ${SETUP_ENV}

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
#        ActsExampleMaterialMappingGeneric, ActsExampleReadCsvGeneric,
#        ActsRecTruthTracks, ActsRecVertexReader and ActsSimFatrasTGeo as no
#        input data file is provided and it's unclear how to get one.
#
# FIXME: Cannot auto-test ActsExampleGeometryTGeo, ActsExampleHepMC3 and
#        ActsExamplePropagationTGeo as they do not reliably exit a nonzero
#        status code upon major failure (e.g. input not found).
#
# FIXME: Cannot test ActsExampleGeantinoRecording, ActsExampleGeometryDD4hep,
#        ActsExampleMaterialMappingDD4hep, ActsExampleMaterialValidationDD4hep,
#        ActsExamplePropagationDD4hep and ActsSimFatrasDD4hep as the dd4hep
#        component is currently disabled due to weird build issues (see above).
#
#        Even if I got DD4hep to work again, MaterialMapping would still be
#        problematic due to its lack of clear input file.
#
# FIXME: The PayloadDetector-based examples ActsExamplePropagationPayload and
#        ActsSimFatrasPayload crash with a bad_any_cast, see
#        https://github.com/acts-project/acts/issues/164 .
#
RUN if [ "$ACTS_BUILD_TYPE" != "Debug" ]; then                                 \
        cd ${ACTS_BUILD_DIR}/Examples                                          \
        && spack build-env acts ../bin/ActsExampleGeometryAligned -n 100       \
        && echo "---------------"                                              \
        && spack build-env acts ../bin/ActsExampleGeometryEmpty -n 100         \
        && echo "---------------"                                              \
        && spack build-env acts ../bin/ActsExampleGeometryGeneric -n 100       \
        && echo "---------------"                                              \
        && spack build-env acts ../bin/ActsExampleGeometryPayload -n 100       \
        && echo "---------------"                                              \
        && spack build-env acts ../bin/ActsExampleHelloWorld -n 100            \
        && echo "---------------"                                              \
        && spack build-env acts                                                \
                 ../bin/ActsExampleMaterialValidationGeneric -n 100            \
        && echo "---------------"                                              \
        && spack build-env acts ../bin/ActsExamplePropagationAligned -n 100    \
        && echo "---------------"                                              \
        && spack build-env acts ../bin/ActsExamplePropagationEmpty -n 100      \
        && echo "---------------"                                              \
        && spack build-env acts ../bin/ActsExamplePropagationGeneric -n 100    \
        && echo "---------------"                                              \
        && spack build-env acts ../bin/ActsGenParticleGun -n 100               \
        && echo "---------------"                                              \
        && spack build-env acts ../bin/ActsGenPythia8 -n 100                   \
        && echo "---------------"                                              \
        && spack build-env acts ../bin/ActsRecVertexFinder -n 100              \
        && echo "---------------"                                              \
        && spack build-env acts ../bin/ActsRecVertexFitter -n 100              \
        && echo "---------------"                                              \
        && spack build-env acts ../bin/ActsRecVertexWriter -n 100              \
        && echo "---------------"                                              \
        && spack build-env acts ../bin/ActsSimFatrasAligned -n 100             \
        && echo "---------------"                                              \
        && spack build-env acts ../bin/ActsSimFatrasGeneric -n 100;            \
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
