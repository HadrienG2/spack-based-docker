# Configure the container's basic properties
ARG DOCKER_REPO=hgrasland
FROM ${DOCKER_REPO}/acts-tests:latest-Debug
LABEL Description="openSUSE Tumbleweed with ACTS and Verrou"
CMD bash
ARG VERROU_VERSION=2.1.0


# === INSTALL VERROU ===

# Install Verrou
RUN spack install verrou@${VERROU_VERSION} ^ ${PYTHON_SPACK_SPEC}

# Verrou's python extensions in global scope
RUN spack activate verrou


# === SETUP AN ACTS DEVELOPMENT ENVIRONMENT ===

# Start working on a development branch of ACTS, uninstalling the system
# version to shrink Docker image size
#
# NOTE: This is morally equivalent to building acts-core@develop, but it's
#       easier to switch to a development branch of hgraslan/acts-core when
#       an issue has been found and must be worked on.
#
RUN spack uninstall -y ${ACTS_SPACK_SPEC}                                      \
    && git clone https://gitlab.cern.ch/acts/acts-core.git                     \
    && spack dev-build --until build -d acts-core ${ACTS_SPACK_SPEC}

# Keep the location of the ACTS build directory around
ENV ACTS_BUILD_DIR=/root/acts-core/spack-build


# === TEST ACTS USING VERROU'S RANDOM-ROUNDING MODE ===

# Bring in the Verrou exclusions
COPY excludes.ex ${ACTS_BUILD_DIR}/

# Record the part of the verrou command line which we'll use everywhere
ENV VERROU_CMD_BASE="valgrind --tool=verrou                                    \
                              --rounding-mode=random                           \
                              --demangle=no                                    \
                              --exclude=${ACTS_BUILD_DIR}/excludes.ex"

# Make sure that CMake is available in the environment as we need it for testing
RUN spack install cmake

# Run the ACTS test suite inside of Verrou, in verbose and single-thread mode
#
# FIXME: The BoundingBoxTest is disabled because the way it operates (grazing
#        incidence rays, leveraging NaNs in intersection computations...) is
#        fundamentally hostile to Verrou.
#
RUN cd ${ACTS_BUILD_DIR}                                                       \
    && activate-spack-view                                                     \
    && ${VERROU_CMD_BASE} --trace-children=yes ctest -V -E "^BoundingBoxTest$"

# Run the integration tests inside of Verrou as well
RUN cd ${ACTS_BUILD_DIR}                                                       \
    && activate-spack-view                                                     \
    && ${VERROU_CMD_BASE} --trace-children=yes                                 \
                          cmake --build . -- integration_tests

# Delta-debug an ACTS unit tests to find out in which ELF symbols Verrou
# perturbations will cause a test failure.
#
# This is an easy way to locate instabilities, which can then be classified as
# genuine numerical problems or false-positives and be fixed or excluded
# accordingly. The provided exclude list was largely generated via this process.
#
# NOTE: In principle, delta-debugging should go down to the granularity of
#       individual source lines, but this currently fails. I think that is
#       because the instabilities are in the libm and I do not have debugging
#       symbols for that. But since we already know that the libm trigonometric
#       function instabilities are a false alarm, this is not a big deal.
#
COPY run.sh cmp.sh ${ACTS_BUILD_DIR}/
RUN cd ${ACTS_BUILD_DIR}                                                       \
    && activate-spack-view                                                     \
    && chmod +x run.sh cmp.sh                                                  \
    && verrou_dd run.sh cmp.sh


# === CLEAN UP BEFORE PUSHING ===

# Get rid of the largest delta-debugging artifacts
RUN cd ${ACTS_BUILD_DIR}/Tests/Integration && rm -rf dd.sym dd.line

# Discard the ACTS build directory to save space
RUN rm -rf ${ACTS_BUILD_DIR}

# Discard the ACTS install, as otherwise user won't be able to rebuild another
RUN spack uninstall -y ${ACTS_SPACK_SPEC}

# Clean up Spack caches and temporary files to shrink the Docker image
RUN spack clean -a
