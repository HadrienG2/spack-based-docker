# Configure the container's basic properties
ARG CONTAINER_REPO=ghcr.io/hadrieng2
ARG ACTS_VERSION=19.2.0
FROM ${CONTAINER_REPO}/acts-tests:${ACTS_VERSION}-Debug
LABEL Description="openSUSE Tumbleweed with ACTS and Verrou"
CMD bash
ARG VERROU_VERSION=2.2.0


# === INSTALL VERROU ===

# Install Verrou
RUN spack install --fail-fast verrou@${VERROU_VERSION} ^ ${PYTHON_SPACK_SPEC}

# Verrou's python extensions in global scope
RUN spack activate verrou


# === SETUP AN ACTS DEVELOPMENT ENVIRONMENT ===

# Start working on a development branch of ACTS, uninstalling the system
# version to shrink container image size
#
# NOTE: This is morally equivalent to building acts@main, but makes it easier to
#       switch to a development branch of acts when an issue has been found by
#       verrou and must be worked on.
#
RUN spack uninstall -y acts                                                    \
    && git clone https://github.com/acts-project/acts.git                      \
    && spack dev-build --until build -d acts ${ACTS_SPACK_SPEC}

# Keep the location of the ACTS build directory around
#
# FIXME: The recent introduction of hashed build dir names to Spack completely
#        breaks both this pattern and the verrou exclude file. Find a way out.
#
ENV ACTS_BUILD_DIR=/root/acts/spack-build


# === TEST ACTS USING VERROU'S RANDOM-ROUNDING MODE ===

# Bring in the Verrou exclusions
COPY excludes.ex ${ACTS_BUILD_DIR}/

# Record the part of the verrou command line which we'll use everywhere
ENV VERROU_CMD_BASE="valgrind --tool=verrou                                    \
                              --rounding-mode=random                           \
                              --demangle=no                                    \
                              --exclude=${ACTS_BUILD_DIR}/excludes.ex"

# Make sure that CMake is available in the environment as we need it for testing
RUN spack install --fail-fast cmake

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
                          cmake --build . -- integrationtests

# Delta-debug ACTS unit tests to find out in which ELF symbols Verrou
# perturbations will cause a test failure.
#
# This is an easy way to locate instabilities, which can then be classified as
# genuine numerical problems or false-positives and be fixed or excluded
# accordingly. The provided exclude list was largely generated via this process.
#
COPY run.sh cmp.sh ${ACTS_BUILD_DIR}/
RUN cd ${ACTS_BUILD_DIR}                                                       \
    && activate-spack-view                                                     \
    && chmod +x run.sh cmp.sh                                                  \
    && verrou_dd_sym run.sh cmp.sh


# === CLEAN UP BEFORE PUSHING ===

# Get rid of the largest delta-debugging artifacts
RUN cd ${ACTS_BUILD_DIR}/Tests/Integration && rm -rf dd.sym dd.line

# Discard the ACTS build directory to save space
RUN rm -rf ${ACTS_BUILD_DIR}

# Discard the ACTS install, as otherwise user won't be able to rebuild another
RUN spack uninstall -y acts

# Clean up Spack caches and temporary files to shrink the container image
RUN spack gc -y && spack clean -a
