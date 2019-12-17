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
# FIXME: PyROOT does not seem to actually work, figure out why.
#
ENV ROOT_SPACK_SPEC="root@${ROOT_VERSION} cxxstd=${ROOT_CXX_STANDARD} -davix   \
                     -examples +gdml -minuit +opengl +python +root7 -rootfit   \
                     +tbb +threads -tiff -tmva -unuran -vdt +x -xml            \
                         ^ mesa -llvm                                          \
                         ^ python -pythoncmd"

# Install ROOT
RUN echo "Installing ${ROOT_SPACK_SPEC}..." && spack install ${ROOT_SPACK_SPEC}

# Check that the ROOT install works
RUN root.exe -b -q -e "(6*7)-(6*7)"

# Clean up Spack caches and temporary files to shrink the Docker image
RUN spack clean -a
