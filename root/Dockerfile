# Configure the container's basic properties
ARG DOCKER_REPO=hgrasland
FROM ${DOCKER_REPO}/spack-tests
LABEL Description="openSUSE Tumbleweed with ROOT installed"
CMD bash
ARG ROOT_VERSION=6.24.06
ARG ROOT_CXX_STANDARD=17

# Split out a Python Spack specification, we'll need it for Verrou
ENV PYTHON_SPACK_SPEC="python@3: +bz2 -dbm -lzma -pyexpat -sqlite3 -pythoncmd  \
                           ^ gettext -bzip2 -git -xz"

# This is a reasonably minimal ROOT Spack specification. We record it to an
# environment variable so that clients can later use the same ROOT build.
#
# FIXME: Figure out what's wrong with the recently released automake@1.16.3
#
ENV ROOT_SPACK_SPEC="root@${ROOT_VERSION} cxxstd=${ROOT_CXX_STANDARD} -davix   \
                     -examples +gdml -minuit +opengl +pythia8 +python +root7   \
                     -roofit +tbb +threads -tmva -unuran -vdt +x -xml          \
                         ^ automake@:1.16.2                                    \
                         ^ mesa -llvm                                          \
                         ^ ${PYTHON_SPACK_SPEC}"

# Install ROOT
RUN spack install --fail-fast ${ROOT_SPACK_SPEC}

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
RUN spack gc -y && spack clean -a
