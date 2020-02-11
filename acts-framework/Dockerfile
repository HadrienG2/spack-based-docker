# Configure the container's basic properties
#
# NOTE: We do not build on top of acts-tests because we rely on a different ACTS
#       versions and use different dependency build settings.
#
ARG DOCKER_REPO=hgrasland
ARG ROOT_VERSION=6.18.04
FROM ${DOCKER_REPO}/root-tests:${ROOT_VERSION}-cxx17
LABEL Description="openSUSE Tumbleweed with ACTSFW installed"
CMD bash


# Specify a full-featured build of ACTSFW
RUN echo "export ACTSFW_SPACK_SPEC=\"                                          \
              acts-framework@develop +dd4hep +geant4 +pythia8 +tgeo            \
                  ^ boost -atomic -chrono cxxstd=17 -date_time -exception      \
                          +filesystem -graph -iostreams -locale -log -math     \
                          +multithreaded +pic +program_options -random -regex  \
                          -serialization +shared -signals -system +test        \
                          -thread -timer -wave                                 \
                  ^ ${ROOT_SPACK_SPEC}                                         \
         \"">> ${SETUP_ENV}

# Install ACTSFW
RUN spack install --keep-stage ${ACTSFW_SPACK_SPEC}

# Run the framework examples
#
# FIXME: Cannot test ACTFWBFieldExample, ACTFWBFieldAccessExample,
#        ACTFWDD4hepMaterialMappingExample, ACTFWGenericMaterialMappingExample
#        ACTFWGenericReadCsvExample and ACTFWPayloadPropagationExample as no
#        input data file is provided and it's unclear how to get one.
#
# FIXME: Cannot reliably test ACTFWTGeoGeometryExample and
#        ACTFWTGeoPropagationExample as they do not reliably emit a nonzero
#        status code on exit.
#
# FIXME: Cannot test ACTFWGeantinoRecordingExample as it crashes with a double
#        free due to G4AssemblyStore ownership issues as of Geant4 10.5p1,
#        should try again with a later Geant4 release.
#
RUN spack cd --build-dir ${ACTSFW_SPACK_SPEC}                                  \
    && activate-spack-view                                                     \
    && ACTFWAlignedFatrasExample -n 100                                        \
    && echo "---------------"                                                  \
    && ACTFWAlignedGeometryExample -n 100                                      \
    && echo "---------------"                                                  \
    && ACTFWAlignedPropagationExample -n 100                                   \
    && echo "---------------"                                                  \
    && ACTFWDD4hepGeometryExample -n 100                                       \
    && echo "---------------"                                                  \
    && ACTFWDD4hepMaterialValidationExample -n 100                             \
    && echo "---------------"                                                  \
    && ACTFWDD4hepPropagationExample -n 100                                    \
    && echo "---------------"                                                  \
    && ACTFWEmptyGeometryExample -n 100                                        \
    && echo "---------------"                                                  \
    && ACTFWEmptyPropagationExample -n 100                                     \
    && echo "---------------"                                                  \
    && ACTFWGenericFatrasExample -n 100                                        \
    && echo "---------------"                                                  \
    && ACTFWGenericGeometryExample -n 100                                      \
    && echo "---------------"                                                  \
    && ACTFWGenericMaterialValidationExample -n 100                            \
    && echo "---------------"                                                  \
    && ACTFWGenericPropagationExample -n 100                                   \
    && echo "---------------"                                                  \
    && ACTFWHelloWorldExample -n 100                                           \
    && echo "---------------"                                                  \
    && ACTFWPayloadFatrasExample -n 100                                        \
    && echo "---------------"                                                  \
    && ACTFWPayloadGeometryExample -n 100                                      \
    && echo "---------------"                                                  \
    && ActsParticleGun -n 100                                                  \
    && echo "---------------"                                                  \
    && ActsPythia8 -n 100                                                      \
    && echo "---------------"                                                  \
    && ACTFWVertexFinderExample -n 100                                         \
    && echo "---------------"                                                  \
    && ACTFWVertexFitterExample -n 100                                         \
    && echo "---------------"                                                  \
    && ACTFWVertexReaderExample -n 100                                         \
    && echo "---------------"                                                  \
    && ACTFWVertexWriterExample -n 100

# Discard the framework install: the goal is to provide a known-good framework
# build environment, but the framework is not terribly useful per se.
RUN spack uninstall -y ${ACTSFW_SPACK_SPEC}

# Clean up Spack caches and temporary file to shrink the Docker image
RUN spack clean -a
