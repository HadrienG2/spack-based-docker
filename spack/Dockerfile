# Configure the container's basic properties
FROM opensuse/tumbleweed
LABEL Description="openSUSE Tumbleweed with Spack installed"
CMD bash
SHELL ["/bin/bash", "-c"]

# Build an environment setup script that works during docker build
#
# NOTE: This trickery is necessary because docker build commands are run in a
#       shell which is neither a login shell nor an interactive shell, and
#       cannot be easily turned into either. Which means that there is no clean
#       entry point for running environment setup scripts in docker build.
#
RUN touch /root/setup_env.sh                                                   \
    && echo "unset BASH_ENV" > /root/bash_env.sh                               \
    && echo "source /root/setup_env.sh" >> /root/bash_env.sh                   \
    && echo "source /root/setup_env.sh" >> /root/.bashrc
ENV BASH_ENV="/root/bash_env.sh"                                               \
    SETUP_ENV="/root/setup_env.sh"

# By default, Docker runs commands at the filesystem root (/). It is cleaner and
# more idiomatic to run them in our home directory (which is /root) instead.
WORKDIR /root

# Update the host system
RUN zypper ref && zypper dup -y

# Install Spack's dependencies
RUN zypper in -y bzip2 curl gcc gcc-c++ gcc-fortran git gzip make patch python \
                 python-xml tar unzip xz

# Install an environment module system
RUN zypper in -y lua-lmod                                                      \
    && echo "source /usr/share/lmod/lmod/init/bash" >> "$SETUP_ENV"

# Download Spack
RUN cd /opt && git clone --depth=1 https://github.com/spack/spack.git

# Setup the environment for running Spack
RUN echo "source /opt/spack/share/spack/setup-env.sh" >> "$SETUP_ENV"

# Some build script such as tar's do not like Docker's habit of running
# everything as root, and need a little convincing
ENV FORCE_UNSAFE_CONFIGURE=1

# Discard the system package cache to save up space
RUN zypper clean
