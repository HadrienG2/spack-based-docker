# Configure the container's basic properties
FROM opensuse/tumbleweed
LABEL Description="openSUSE Tumbleweed with Spack installed"
CMD bash
SHELL ["/bin/bash", "-c"]

# Build an environment setup script that is executed both during the Docker
# image build process (before every RUN command) and when an image is started
# in interactive mode (via "docker run").
#
# This is harder than it sounds because...
#
# 1. RUN commands are run in a shell that, in bash terminology, is neither
#    a login shell nor an interactive shell. So our only hook for injecting
#    environment setup is BASH_ENV, which is queried for an environment setup
#    file to be sourced whenever a non-interactive shell starts.
# 2. Interactive docker runs do not use a login shell (and we probably don't
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
RUN touch /root/setup_env.sh                                                   \
    && echo 'if [ -n "${BASH_ENV}" ]; then                                     \
                 unset BASH_ENV;                                               \
                 source /root/setup_env.sh;                                    \
             fi' > /root/bash_env.sh                                           \
    && echo "source /root/bash_env.sh" >> /root/.bashrc
ENV BASH_ENV="/root/bash_env.sh"                                               \
    SETUP_ENV="/root/setup_env.sh"

# By default, Docker runs commands at the filesystem root (/). It is cleaner and
# more idiomatic to run them in our home directory (which is /root) instead.
WORKDIR /root

# Update the host system
RUN zypper ref && zypper dup -y

# Install Spack's dependencies
#
# FIXME: Switch back to GCC once ROOT's deps build with GCC 10.
#
RUN zypper in -y bzip2 clang curl gcc-fortran git gzip libstdc++-devel make    \
                 patch python3 subversion tar unzip xz

# Install dependencies of our own scripts
RUN zypper in -y python3-PyYAML

# Download Spack
#
# This extended command allows switching back to my Spack fork when I'm working
# on some package change that hasn't been submitted upstream yet.
#
RUN cd /opt                                                                    \
    && git clone --depth=1                                                     \
                 --branch=develop                                              \
                 https://github.com/spack/spack.git

# Setup the environment for running Spack
RUN echo "source /opt/spack/share/spack/setup-env.sh" >> "${SETUP_ENV}"

# Use a large spack download timeout to accomodate for the general flakiness of
# the x.org and freedesktop.org servers, which may take a _while_ to answer...
RUN spack config add config:connect_timeout:300

# By default, spack build in -march=native mode, which is good for performance
# but bad for portability. For Docker images this is not the right choice.
RUN spack config add packages:all:target:[x86_64]

# Have spack search the system compilers, then make sure that it uses the
# "-fno-omit-frame-pointer" flag on compilers that are known to support it.
#
# Also, patch the clang compiler config to use gfortran for Fortran code.
#
# FIXME: Add back the -O3 flag once Acts build resource consumption has improved
#        enough that it doesn't OOM on 4 threads + 16 GB of RAM
#
RUN spack compiler find
COPY configure_compilers.py /root
RUN python3 ~/configure_compilers.py

# FIXME: Forbid GCC use as some ROOT deps like libdrm don't build with GCC 10
RUN spack compiler rm gcc

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
ENV SPACK_ENV_NAME="docker-spack"
RUN spack env create ${SPACK_ENV_NAME}                                         \
    && echo "spack env activate -V ${SPACK_ENV_NAME}" >> "${SETUP_ENV}"        \
    && echo "activate-spack-view() {                                           \
                 spack env deactivate;                                         \
                 spack env activate ${SPACK_ENV_NAME};                         \
            }" >> "${SETUP_ENV}"                                               \
    && echo "export -f activate-spack-view" >> "${SETUP_ENV}"

# Some build script such as tar's do not like Docker's habit of running
# everything as root, and need a little convincing
ENV FORCE_UNSAFE_CONFIGURE=1

# Discard the system package cache to save up space
RUN zypper clean -a
