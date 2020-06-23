# Configure the container's basic properties
ARG DOCKER_REPO=hgrasland
FROM ${DOCKER_REPO}/spack-tests
LABEL Description="openSUSE Tumbleweed with ROOT installed"
CMD bash
ARG ROOT_VERSION=6.20.04
ARG ROOT_CXX_STANDARD=17

# FIXME: Currently, some dependencies of ROOT, such as libdrm, do not build with
#        GCC 10. Switching to a clang-based build until this is resolved.
#
#        It's better to make the LLVM build as lean as possible, because as soon
#        as we switch to clang as our main compiler, all GCC-built libs will be
#        unusable due to spack's very strict understanding of ABI compatibility.
#
ENV LLVM_SPACK_SPEC="llvm -gold -lldb                                          \
                         ^ cmake -ncurses -openssl                             \
                         ^ gettext -bzip2 -curses -git -tar -xz                \
                         ^ hwloc -libxml2 -pci                                 \
                         ^ perl -cpanm -threads                                \
                         ^ python -bz2 -dbm -libxml2 -lzma -pyexpat +pythoncmd \
                                  -readline -sqlite3 -ssl -tix -zlib"
RUN spack install ${LLVM_SPACK_SPEC}
RUN python3 ~/set_compiler_flags.py
RUN spack gc -y

# Split out a Python Spack specification, we'll need it for Verrou
ENV PYTHON_SPACK_SPEC="python@3: -bz2 -dbm -lzma -pyexpat -sqlite3 -pythoncmd  \
                           ^ gettext -bzip2 -git -xz                           \
                           % ${LLVM_SPACK_SPEC}"

# This is a reasonably minimal ROOT Spack specification. We record it to an
# environment variable so that clients can later use the same ROOT build.
ENV ROOT_SPACK_SPEC="root@${ROOT_VERSION} cxxstd=${ROOT_CXX_STANDARD} -davix   \
                     -examples +gdml -minuit +opengl +pythia8 +python +root7   \
                     -rootfit +tbb +threads -tmva -unuran -vdt +x -xml         \
                         ^ binutils -gold -nls                                 \
                         ^ mesa -llvm                                          \
                         ^ ${PYTHON_SPACK_SPEC}"

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
RUN spack gc -y && spack clean -a
