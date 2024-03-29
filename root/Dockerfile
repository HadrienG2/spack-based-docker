# Configure the container's basic properties
ARG CONTAINER_REPO=ghcr.io/hadrieng2
FROM ${CONTAINER_REPO}/spack-tests
LABEL Description="openSUSE Tumbleweed with ROOT installed"
CMD bash
ARG ROOT_VERSION=6.30.02
ARG ROOT_CXX_STANDARD=17

# Split out a Python Spack specification, we'll need it for Verrou
ENV PYTHON_SPACK_SPEC="python@3: +bz2 -dbm -lzma -pyexpat -sqlite3 -pythoncmd  \
                           ^ gettext -bzip2 -git -xz"

# This is a reasonably minimal ROOT Spack specification. We record it to an
# environment variable so that clients can later use the same ROOT build.
ENV ROOT_SPACK_SPEC="root@${ROOT_VERSION} cxxstd=${ROOT_CXX_STANDARD} -davix   \
                     -examples +gdml -minuit -opengl -pythia8 +python +root7   \
                     -roofit +tbb +threads -tmva -unuran -vdt -x -xml          \
                         ^ ${PYTHON_SPACK_SPEC}"

# Install ROOT
RUN spack install --add --fail-fast ${ROOT_SPACK_SPEC}

# Check that the ROOT install works, including PyROOT:
#
# - Can we evaluate C++ expressions?
# - Can we see ROOT from Python?
#
RUN activate-spack-view                                                        \
    && root.exe -b -q -e '(6*7)-(6*7)'                                         \
    && python3 -c 'import ROOT'

# Clean up Spack caches and temporary files to shrink the container image
RUN spack gc -y && spack clean -a
