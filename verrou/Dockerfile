# Configure the container's basic properties
ARG DOCKER_REPO=hgrasland
FROM ${DOCKER_REPO}/spack-tests
LABEL Description="openSUSE Tumbleweed with Verrou installed"
CMD bash
ARG VERROU_VERSION=2.1.0

# Install verrou
RUN spack install verrou@${VERROU_VERSION}

# Clean up Spack caches and temporary files to shrink the Docker image
RUN spack clean -a
