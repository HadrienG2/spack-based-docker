#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# Build parameters
DOCKER_REPO="docker.io/hgrasland"
VERROU_VERSION="2.2.0"
ROOT_VERSION="6.24.06"
ACTS_VERSION="17.0.0"
ACTS_BUILD_TYPES=(
    "Debug"
    "RelWithDebInfo"
)

echo "*** Updating base Tumbleweed image ***"
buildah pull registry.opensuse.org/opensuse/tumbleweed

# Build an OCI image, then prune builder state
build_tag_prune() {
    # First argument is the tag, you can add more build options after that
    buildah build --layers                                                     \
                  --squash                                                     \
                  --format=docker                                              \
                  --build-arg DOCKER_REPO=${DOCKER_REPO}                       \
                  --build-arg VERROU_VERSION=${VERROU_VERSION}                 \
                  --build-arg ROOT_VERSION=${ROOT_VERSION}                     \
                  --build-arg ACTS_VERSION=${ACTS_VERSION}                     \
                  --tag ${DOCKER_REPO}/$*
    buildah rm -a
    buildah rmi -p
}

echo "*** Building basic Spack image ***"
cd spack
build_tag_prune spack-tests:latest

# FIXME: For some reason that has yet to be understood, Verrou crashes with
#        SIGILL on my home desktop. So I can't test Verrou-related builds while
#        COVID telework is ongoing... unless I manage to debug that.
#
# echo "*** Building Verrou image ***"
# cd ../verrou
# build_tag_prune verrou-tests:${VERROU_VERSION}

cd ../root
echo "*** Building ROOT C++17 image ***"
build_tag_prune root-tests:${ROOT_VERSION}-cxx17                               \
                --build-arg ROOT_CXX_STANDARD=17

cd ../acts
for BUILD_TYPE in ${ACTS_BUILD_TYPES[@]}; do
    echo "***Building ACTS ${BUILD_TYPE} image ***"
    build_tag_prune acts-tests:${ACTS_VERSION}-${BUILD_TYPE}                   \
                    --build-arg ACTS_BUILD_TYPE=${BUILD_TYPE}
done

# FIXME: For some reason that has yet to be understood, Verrou crashes with
#        SIGILL on my home desktop. So I can't test Verrou-related builds while
#        COVID telework is ongoing... unless I manage to debug that.
#
# echo "*** Building Verrou-enhanced ACTS dev image ***"
# cd ../acts-verrou
# build_tag_prune acts-verrou-tests:latest

echo "*** Pushing images to the Docker Hub ***"
buildah push ${DOCKER_REPO}/spack-tests
# buildah push ${DOCKER_REPO}/verrou-tests:${VERROU_VERSION}
buildah push ${DOCKER_REPO}/root-tests:${ROOT_VERSION}-cxx17
for BUILD_TYPE in ${ACTS_BUILD_TYPES[@]}; do
    buildah push ${DOCKER_REPO}/acts-tests:${ACTS_VERSION}-${BUILD_TYPE}
done
# buildah push ${DOCKER_REPO}/acts-verrou-tests
