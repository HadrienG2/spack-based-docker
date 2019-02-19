#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# Build parameters
DOCKER_REPO="hgrasland"
VERROU_VERSION="2.1.0"
ROOT_VERSION="6.16.00"
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
cd spack-docker
docker build --squash --tag ${DOCKER_REPO}/spack-tests:latest .

echo "*** Building Verrou image ***"
cd ../verrou-docker
docker build --squash --tag ${DOCKER_REPO}/verrou-tests:${VERROU_VERSION}      \
                      --build-arg VERROU_VERSION=${VERROU_VERSION} .
docker tag ${DOCKER_REPO}/verrou-tests:${VERROU_VERSION}                       \
           ${DOCKER_REPO}/verrou-tests:latest

cd ../root-docker
echo "*** Building ROOT C++17 image ***"
docker build --squash                                                          \
             --tag ${DOCKER_REPO}/root-tests:${ROOT_VERSION}-cxx17             \
             --build-arg ROOT_CXX_STANDARD=17                                  \
             --build-arg ROOT_VERSION=${ROOT_VERSION} .
docker tag ${DOCKER_REPO}/root-tests:${ROOT_VERSION}-cxx17                     \
           ${DOCKER_REPO}/root-tests:latest-cxx17

echo "***Building Gaudi image ***"
cd ../gaudi-docker
docker build --squash --tag ${DOCKER_REPO}/gaudi-tests:latest .

cd ../acts-docker
for BUILD_TYPE in ${ACTS_BUILD_TYPES[@]}; do
    echo "***Building ACTS ${BUILD_TYPE} image ***"
    docker build --squash --tag ${DOCKER_REPO}/acts-tests:latest-${BUILD_TYPE} \
                          --build-arg ACTS_BUILD_TYPE=${BUILD_TYPE} .
done

# TODO: Fix C++17 build for ACTSFW, see bug acts-framework#129
echo "*** Skipping ACTS test framework image due to C++17 incompatibility ***"
# echo "***Building ACTS test framework image ***"
# cd ../acts-framework-docker
# docker build --squash --tag ${DOCKER_REPO}/acts-framework-tests:latest .

echo "***Building Verrou-enhanced ACTS dev image ***"
cd ../acts-verrou-docker
docker build --squash --tag ${DOCKER_REPO}/acts-verrou-tests:latest .

echo "*** Pushing images to the Docker Hub ***"
docker push ${DOCKER_REPO}/spack-tests
docker push ${DOCKER_REPO}/verrou-tests
docker push ${DOCKER_REPO}/root-tests
docker push ${DOCKER_REPO}/gaudi-tests
docker push ${DOCKER_REPO}/acts-tests
# TODO: docker push ${DOCKER_REPO}/acts-framework-tests
docker push ${DOCKER_REPO}/acts-verrou-tests
