# Configure the container's basic properties
FROM hgrasland/spack-tests
LABEL Description="openSUSE Tumbleweed with ROOT installed"
CMD bash
ARG ROOT_VERSION=6.16.00
ARG ROOT_CXX_STANDARD=17

# This is a reasonably minimal ROOT Spack specification. We record it to an
# environment variable so that clients can later use the same ROOT build.
ENV ROOT_SPACK_SPEC="root@${ROOT_VERSION} cxxstd=${ROOT_CXX_STANDARD} -davix   \
                     -examples +gdml -memstat -minuit +opengl +root7 -rootfit  \
                     +rpath +sqlite +ssl +tbb +threads -tiff -tmva -unuran     \
                     -vdt +x -xml"

# Install ROOT
RUN echo "Installing ${ROOT_SPACK_SPEC}..." && spack install ${ROOT_SPACK_SPEC}

# Prepare the environment for running ROOT
RUN echo "spack load ${ROOT_SPACK_SPEC}" >> "$SETUP_ENV"

# Check that the ROOT install works
RUN root.exe -b -q -e "(6*7)-(6*7)"
