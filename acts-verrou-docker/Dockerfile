# Configure the container's basic properties
FROM hgrasland/acts-tests:latest-Debug
LABEL Description="openSUSE Tumbleweed with ACTS and Verrou"
CMD bash


# === INSTALL VERROU ===

# Install Verrou
RUN spack install verrou@2.1.0 ^ python -pythoncmd

# Bring Python, Verrou, and Verrou's python extensions in global scope
RUN spack activate verrou                                                      \
    && echo "spack load python@3 -pythoncmd" >> ${SETUP_ENV}                   \
    && echo "spack load verrou" >> ${SETUP_ENV}


# === SETUP AN ACTS DEVELOPMENT ENVIRONMENT ===

# Start working on a development branch of ACTS, uninstalling the system
# version to shrink Docker image size
RUN spack uninstall -y ${ACTS_SPACK_SPEC}                                      \
    && git clone https://gitlab.cern.ch/hgraslan/acts-core.git                 \
    && spack diy -d acts-core ${ACTS_SPACK_SPEC}

# Keep the location of the ACTS build directory around
ENV ACTS_BUILD_DIR=/root/acts-core/spack-build


# === TEST ACTS USING VERROU'S RANDOM-ROUNDING MODE ===

# Bring in the files needed for verrou-based testing
COPY excludes.ex ${ACTS_BUILD_DIR}/
COPY run.sh cmp.sh ${ACTS_BUILD_DIR}/Tests/Integration/

# Record the part of the verrou command line which we'll use everywhere
ENV VERROU_CMD_BASE="valgrind --tool=verrou                                    \
                              --rounding-mode=random                           \
                              --demangle=no                                    \
                              --exclude=${ACTS_BUILD_DIR}/excludes.ex"

# Run the ACTS test suite inside of Verrou, in verbose and single-thread mode
RUN cd ${ACTS_BUILD_DIR}                                                       \
    && spack load cmake                                                        \
    && ${VERROU_CMD_BASE} --trace-children=yes ctest -V

# Run the integration tests inside of Verrou as well
RUN cd ${ACTS_BUILD_DIR}/Tests/Integration                                     \
    && ${VERROU_CMD_BASE} ./PropagationTests                                   \
    && ${VERROU_CMD_BASE} ./SeedingTest

# Delta-debug the ACTS propagation to find its numerical instability regions.
# This is how the libm exclusion file was generated.
#
# NOTE: In principle, delta-debugging should go down to the granularity of
#       individual source lines, but this currently fails. I think that is
#       because the instabilities are in the libm and I do not have debugging
#       symbols for that. But since we already know that the libm trigonometric
#       function instabilities are a false alarm, this is not a big deal.
#
RUN cd ${ACTS_BUILD_DIR}/Tests/Integration                                     \
    && chmod +x run.sh cmp.sh                                                  \
    && verrou_dd run.sh cmp.sh


# === CLEAN UP BEFORE PUSHING ===

# Get rid of the largest delta-debugging artifacts
RUN cd ${ACTS_BUILD_DIR}/Tests/Integration && rm -rf dd.sym dd.line

# Discard the ACTS build directory to save space
RUN rm -rf ${ACTS_BUILD_DIR}

# Discard the ACTS install, as otherwise user won't be able to rebuild another
RUN spack uninstall -y ${ACTS_SPACK_SPEC}