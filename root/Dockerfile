# Configure the container's basic properties
ARG DOCKER_REPO=hgrasland
FROM ${DOCKER_REPO}/spack-tests
LABEL Description="openSUSE Tumbleweed with ROOT installed"
CMD bash
ARG ROOT_VERSION=6.18.04
ARG ROOT_CXX_STANDARD=17

# This is a reasonably minimal ROOT Spack specification. We record it to an
# environment variable so that clients can later use the same ROOT build.
ENV ROOT_SPACK_SPEC="root@${ROOT_VERSION} cxxstd=${ROOT_CXX_STANDARD} -davix   \
                     -examples +gdml -minuit +opengl +python +root7 -rootfit   \
                     +tbb +threads -tmva -unuran -vdt +x -xml                  \
                         ^ binutils -gold -nls                                 \
                         ^ gettext -bzip2 -git -xz                             \
                         ^ mesa -llvm                                          \
                         ^ python@3: -bz2 -dbm -lzma -pyexpat -sqlite3         \
                                     -pythoncmd"

# Install ROOT
RUN spack install ${ROOT_SPACK_SPEC}

# Check that the ROOT install works, including PyROOT:
#
# - Can we evaluate C++ expressions?
# - Can we call Python from ROOT?
# - Can we see ROOT from Python?
#
RUN activate-spack-view                                                        \
    && root.exe -b -q -e '(6*7)-(6*7)'                                         \
    && root.exe -b -q -e 'TPython::Exec( "print(1 + 1)" ) ? 0 : 42'            \
    && python3 -c 'import ROOT'

# Clean up Spack caches and temporary files to shrink the Docker image
RUN spack clean -a
