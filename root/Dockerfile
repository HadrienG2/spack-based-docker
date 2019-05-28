# Configure the container's basic properties
ARG DOCKER_REPO=hgrasland
FROM ${DOCKER_REPO}/spack-tests
LABEL Description="openSUSE Tumbleweed with ROOT installed"
CMD bash
ARG ROOT_VERSION=6.16.00
ARG ROOT_CXX_STANDARD=17

# This is a reasonably minimal ROOT Spack specification. We record it to an
# environment variable so that clients can later use the same ROOT build.
#
# FIXME: Bring back +x +opengl once either of the following is true:
#        1. ROOT's inner LLVM CMake config supports Python 3
#        2. Spack brings back a Python 2-compatible Mesa releases (e.g. 18.x)
#        3. Spack supports concurrently installing Python 2 and Python 3
#
ENV ROOT_SPACK_SPEC="root@${ROOT_VERSION} cxxstd=${ROOT_CXX_STANDARD} -davix   \
                     -examples +gdml -minuit -opengl +root7 -rootfit +sqlite   \
                     +ssl +tbb +threads -tiff -tmva -unuran +vdt -x -xml"

# Install ROOT
RUN echo "Installing ${ROOT_SPACK_SPEC}..." && spack install ${ROOT_SPACK_SPEC}

# Prepare the environment for running ROOT
RUN echo "spack load ${ROOT_SPACK_SPEC}" >> "$SETUP_ENV"

# Check that the ROOT install works
RUN root.exe -b -q -e "(6*7)-(6*7)"

# Clean up Spack caches and temporary files to shrink the Docker image
RUN spack clean -a
