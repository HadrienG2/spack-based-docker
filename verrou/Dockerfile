# Configure the container's basic properties
ARG DOCKER_REPO=hgrasland
FROM ${DOCKER_REPO}/spack-tests
LABEL Description="openSUSE Tumbleweed with Verrou installed"
CMD bash
ARG VERROU_VERSION=2.1.0

# Install verrou, golfing the dependencies a bit to speed up the build
RUN spack install verrou@${VERROU_VERSION}                                     \
                      ^ gettext -bzip2 -git -tar -xz                           \
                      ^ m4 -sigsegv                                            \
                      ^ perl -cpanm -threads                                   \
                      ^ python -bz2 -ctypes -dbm -lzma -pyexpat -pythoncmd     \
                               -sqlite3 -ssl -zlib

# Clean up Spack caches and temporary files to shrink the Docker image
RUN spack clean -a
