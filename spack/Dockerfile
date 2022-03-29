# Configure the container's basic properties
FROM registry.opensuse.org/opensuse/tumbleweed
LABEL Description="openSUSE Tumbleweed with Spack installed"
CMD bash
SHELL ["/bin/bash", "-c"]

# Build an environment setup script that is executed both during the container
# image building process (before every RUN command) and when an image is started
# in interactive mode (via "docker run").
#
# This is harder than it sounds because...
#
# 1. RUN commands are run in a shell that, in bash terminology, is neither
#    a login shell nor an interactive shell. So our only hook for injecting
#    environment setup is BASH_ENV, which is queried for an environment setup
#    file to be sourced whenever a non-interactive shell starts.
# 2. Interactive container runs do not use a login shell (and we probably don't
#    want them to since /etc/profile does too much stuff), only an interactive
#    shell. So our only hook for injecting environment setup is bashrc files,
#    which are sourced anytime an interactive shell starts.
# 3. Some aspects of our environment setup should only run once per run, either
#    because they're not reentrant or unacceptably costly, and both hooks above
#    can lead to the environment setup script being sourced multiple times.
#
# The way we resolve this is that we point both BASH_ENV and bashrc to a script
# which checks if BASH_ENV is set, and if so unsets it and runs our environment
# setup. This works because...
#
# - The script is invoked for both interactive and non-interactive shells
# - Unsetting BASH_ENV after setup cleans up the environment and ensures that
#   the environment setup script is only run once.
#
# However, it only works with containers that use Docker-style layering where
# new environment is sourced between one RUN statement and the following one.
# For containers systems that do not follow this model like Singularity, another
# approach will need to be found.
#
RUN touch /root/setup_env.sh                                                   \
    && echo 'if [ -n "${BASH_ENV}" ]; then                                     \
                 unset BASH_ENV;                                               \
                 source /root/setup_env.sh;                                    \
             fi' > /root/bash_env.sh                                           \
    && echo "source /root/bash_env.sh" >> /root/.bashrc
ENV BASH_ENV="/root/bash_env.sh"                                               \
    SETUP_ENV="/root/setup_env.sh"

# By default, containers runs commands at the filesystem root (/). It is cleaner
# and more idiomatic to run them in our home directory (which is /root) instead.
WORKDIR /root

# Update the host system
RUN zypper ref && zypper -n dup

# Install Spack's dependencies
RUN zypper -n in bzip2 curl gcc gcc-c++ gcc-fortran git gzip make patch        \
                 python3 subversion tar unzip xz

# Install dependencies of our own scripts/projects
RUN zypper -n in git-lfs python3-PyYAML

# Set up an Intel oneAPI dev environment
RUN zypper addrepo https://yum.repos.intel.com/oneapi oneAPI                   \
    && zypper --gpg-auto-import-keys ref                                       \
    && zypper -n in coreutils pattern:devel_C_C++ findutils grep kmod          \
                    pkg-config procps sed util-linux which                     \
    && zypper -n in cmake intel-basekit libstdc++-devel                        \
    && echo "source /opt/intel/oneapi/setvars.sh >/dev/null" >> "${SETUP_ENV}"

# Check that the environment was set up correctly
RUN dpcpp --version

# Download Spack
#
# This extended command allows switching back to my Spack fork when I'm working
# on some package change that hasn't been submitted upstream yet.
#
# FIXME: Go back to spack upstream once fixes are integrated to Spack
#
RUN cd /opt                                                                    \
    && git clone --depth=1                                                     \
                 --branch=acts-fixes                                           \
                 https://github.com/HadrienG2/spack.git

# Setup the environment for running Spack
RUN echo "source /opt/spack/share/spack/setup-env.sh" >> "${SETUP_ENV}"

# By default, spack build in -march=native mode, which is good for performance
# but bad for portability. For container images this is not the right choice.
RUN spack config add packages:all:target:[x86_64]

# Use all available CPU cores
RUN spack config add config:build_jobs:$(nproc)

# Have spack search the system compilers, then make sure that it uses the
# "-O3 -fno-omit-frame-pointer" flags on compilers that are known to support it.
RUN spack compiler find
COPY configure_compilers.py /root
RUN python3 ~/configure_compilers.py

# Setup a Spack environment
#
# Largely modeled after Python virtual environments, Spack environments provide
# an easy way to bring Spack-installed packages into shell "scope", eliminating
# the need for slow and cumbersome environment modules.
#
# One can separate the actions of specifying in which environment Spack is
# operating and actually setting all the PATHs accordingly. Here, we're only
# doing the former, because doing the latter has harmful side-effects on Spack
# and the shell, so it should only be done as the last step before using a
# package, with the "activate-spack-view" shell function.
#
ENV SPACK_ENV_NAME="spack-based-docker"
RUN spack env create ${SPACK_ENV_NAME}                                         \
    && echo "spack env activate -V ${SPACK_ENV_NAME}" >> "${SETUP_ENV}"        \
    && echo "activate-spack-view() {                                           \
                 spack env deactivate;                                         \
                 spack env activate ${SPACK_ENV_NAME};                         \
            }" >> "${SETUP_ENV}"                                               \
    && echo "export -f activate-spack-view" >> "${SETUP_ENV}"

# Some build script such as tar's do not like containers' habit of running
# everything as root, and need a little convincing
ENV FORCE_UNSAFE_CONFIGURE=1

# Discard the system package cache to save up space
RUN zypper clean -a
