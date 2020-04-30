# Configure the container's basic properties
#
# NOTE: We do not build on top of acts-tests because we rely on a different ACTS
#       versions and use different dependency build settings.
#
ARG DOCKER_REPO=hgrasland
ARG ROOT_VERSION=6.20.02
FROM ${DOCKER_REPO}/root-tests:${ROOT_VERSION}-cxx17
LABEL Description="openSUSE Tumbleweed with ACTSFW installed"
CMD bash


# Specify a full-featured build of ACTSFW
#
# FIXME: xerces-c cxxstd must be forced to "11" because it's "default" by
#        by default, Geant4 asks for "11", and Spack isn't smart enough to
#        figure out that these two constraints are compatible.
#
# FIXME: dd4hep is disabled because enabling it triggers a link error caused by
#        what looks like a CMake dependency spaghetti. I'm not touching that.
#
ENV ACTSFW_SPACK_SPEC="acts@master -dd4hep +digitization +examples +fatras     \
                                   +geant4 +identification +hepmc3 +json       \
                                   +pythia8 +tgeo                              \
                           ^ boost -atomic -chrono cxxstd=17 -date_time        \
                                   -exception +filesystem -graph -iostreams    \
                                   -locale -log -math +multithreaded +pic      \
                                   +program_options -random -regex             \
                                   -serialization +shared -signals -system     \
                                   +test -thread -timer -wave                  \
                           ^ ${ROOT_SPACK_SPEC}                                \
                           ^ xerces-c cxxstd=11"

# Install ACTSFW
RUN spack install --keep-stage ${ACTSFW_SPACK_SPEC}

# Run the framework examples
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
RUN spack cd --build-dir ${ACTSFW_SPACK_SPEC}                                  \
    && cd Examples                                                             \
    && activate-spack-view                                                     \
    && ActsExampleGeometryAligned -n 100                                       \
    && echo "---------------"                                                  \
    && ActsExampleGeometryEmpty -n 100                                         \
    && echo "---------------"                                                  \
    && ActsExampleGeometryGeneric -n 100                                       \
    && echo "---------------"                                                  \
    && ActsExampleGeometryPayload -n 100                                       \
    && echo "---------------"                                                  \
    && ActsExampleHelloWorld -n 100                                            \
    && echo "---------------"                                                  \
    && ActsExampleMaterialValidationGeneric -n 100                             \
    && echo "---------------"                                                  \
    && ActsExamplePropagationAligned -n 100                                    \
    && echo "---------------"                                                  \
    && ActsExamplePropagationEmpty -n 100                                      \
    && echo "---------------"                                                  \
    && ActsExamplePropagationGeneric -n 100                                    \
    && echo "---------------"                                                  \
    && ActsGenParticleGun -n 100                                               \
    && echo "---------------"                                                  \
    && ActsGenPythia8 -n 100                                                   \
    && echo "---------------"                                                  \
    && ActsRecVertexFinder -n 100                                              \
    && echo "---------------"                                                  \
    && ActsRecVertexFitter -n 100                                              \
    && echo "---------------"                                                  \
    && ActsRecVertexWriter -n 100                                              \
    && echo "---------------"                                                  \
    && ActsSimFatrasAligned -n 100                                             \
    && echo "---------------"                                                  \
    && ActsSimFatrasGeneric -n 100

# Discard the framework install: the goal is to provide a known-good framework
# build environment, but the framework is not terribly useful per se.
RUN spack uninstall -y acts

# Clean up Spack caches and temporary file to shrink the Docker image
RUN spack gc -y && spack clean -a
