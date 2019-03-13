# Configure the container's basic properties
ARG DOCKER_REPO=hgrasland
FROM ${DOCKER_REPO}/spack-tests
LABEL Description="openSUSE Tumbleweed with Verrou installed"
CMD bash
ARG VERROU_VERSION=2.1.0

# Install verrou
RUN spack install verrou@${VERROU_VERSION}

# Schedule a Verrou environment to be loaded during container startup
RUN echo "spack load verrou" >> "$SETUP_ENV"
