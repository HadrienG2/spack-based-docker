# Configure the container's basic properties
ARG DOCKER_REPO=hgrasland
FROM ${DOCKER_REPO}/spack-tests
LABEL Description="openSUSE Tumbleweed with Verrou installed"
CMD bash
ARG VERROU_VERSION=2.2.0

# Install verrou, golfing the dependencies a bit to speed up the build
RUN spack install verrou@${VERROU_VERSION}                                     \
                      ^ gettext -bzip2 -git -tar -xz                           \
                      ^ m4 -sigsegv                                            \
                      ^ perl -cpanm -threads                                   \
                      ^ python@3: -bz2 -ctypes -dbm -lzma -pyexpat -pythoncmd  \
                                  -sqlite3 -ssl -zlib

# Enable verrou's python extensions
RUN spack activate verrou

# Check basic Verrou operation
RUN activate-spack-view                                                        \
    && valgrind --tool=verrou --rounding-mode=random                           \
                python3 -c "assert(sum([0.1*i-0.1*i for i in range(100)]) != 0)"

# Clean up Spack caches and temporary files to shrink the Docker image
RUN spack clean -a
