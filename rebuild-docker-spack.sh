#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# Build parameters
DOCKER_REPO="hgrasland"
VERROU_VERSION="2.2.0"
ROOT_VERSION="6.24.02"
ACTS_VERSION="9.1.0"
ACTS_BUILD_TYPES=(
    "Debug"
    "RelWithDebInfo"
)

set +e
docker image ls >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "*** Please start the Docker service before running this script ***"
    exit 42
fi
set -e

echo "*** Updating base Tumbleweed image ***"
docker pull opensuse/tumbleweed

echo "*** Building basic Spack image ***"
cd spack
docker build --no-cache --squash --tag ${DOCKER_REPO}/spack-tests:latest .
docker system prune -f

# FIXME: For some reason that has yet to be understood, Verrou crashes with
#        SIGILL on my home desktop. So I can't test Verrou-related builds while
#        COVID telework is ongoing... unless I manage to debug that.
#
# echo "*** Building Verrou image ***"
# cd ../verrou
# docker build --squash                                                          \
#              --tag ${DOCKER_REPO}/verrou-tests:${VERROU_VERSION}               \
#              --build-arg DOCKER_REPO=${DOCKER_REPO}                            \
#              --build-arg VERROU_VERSION=${VERROU_VERSION}                      \
#              .
# docker system prune -f

cd ../root
echo "*** Building ROOT C++17 image ***"
docker build --squash                                                          \
             --tag ${DOCKER_REPO}/root-tests:${ROOT_VERSION}-cxx17             \
             --build-arg DOCKER_REPO=${DOCKER_REPO}                            \
             --build-arg ROOT_VERSION=${ROOT_VERSION}                          \
             --build-arg ROOT_CXX_STANDARD=17                                  \
             .
docker system prune -f

cd ../acts
for BUILD_TYPE in ${ACTS_BUILD_TYPES[@]}; do
    echo "***Building ACTS ${BUILD_TYPE} image ***"
    docker build --squash                                                      \
                 --tag ${DOCKER_REPO}/acts-tests:${ACTS_VERSION}-${BUILD_TYPE} \
                 --build-arg DOCKER_REPO=${DOCKER_REPO}                        \
                 --build-arg ROOT_VERSION=${ROOT_VERSION}                      \
                 --build-arg ACTS_VERSION=${ACTS_VERSION}                      \
                 --build-arg ACTS_BUILD_TYPE=${BUILD_TYPE}                     \
                 .
    docker system prune -f
done

# FIXME: For some reason that has yet to be understood, Verrou crashes with
#        SIGILL on my home desktop. So I can't test Verrou-related builds while
#        COVID telework is ongoing... unless I manage to debug that.
#
# echo "*** Building Verrou-enhanced ACTS dev image ***"
# cd ../acts-verrou
# docker build --squash                                                          \
#              --tag ${DOCKER_REPO}/acts-verrou-tests:latest                     \
#              --build-arg DOCKER_REPO=${DOCKER_REPO}                            \
#              --build-arg ACTS_VERSION=${ACTS_VERSION}                          \
#              --build-arg VERROU_VERSION=${VERROU_VERSION}                      \
#              .
# docker system prune -f

echo "*** Pushing images to the Docker Hub ***"
docker push ${DOCKER_REPO}/spack-tests
# docker push ${DOCKER_REPO}/verrou-tests:${VERROU_VERSION}
docker push ${DOCKER_REPO}/root-tests:${ROOT_VERSION}-cxx17
for BUILD_TYPE in ${ACTS_BUILD_TYPES[@]}; do
    docker push ${DOCKER_REPO}/acts-tests:${ACTS_VERSION}-${BUILD_TYPE}
done
# docker push ${DOCKER_REPO}/acts-verrou-tests
