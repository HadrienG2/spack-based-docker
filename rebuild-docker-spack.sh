#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# Build parameters
DOCKER_REPO="hgrasland"
VERROU_VERSION="2.1.0"
ROOT_VERSION="6.16.00"
ROOT_CXX_STANDARDS=(
    "14"
    "17"
)
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
for CXX_STD in ${ROOT_CXX_STANDARDS[@]}; do
    echo "*** Building ROOT C++${CXX_STD} image ***"
    docker build --squash                                                      \
                 --tag ${DOCKER_REPO}/root-tests:${ROOT_VERSION}-cxx${CXX_STD} \
                 --build-arg ROOT_CXX_STANDARD=${CXX_STD}                      \
                 --build-arg ROOT_VERSION=${ROOT_VERSION} .
    docker tag ${DOCKER_REPO}/root-tests:${ROOT_VERSION}-cxx${CXX_STD}         \
               ${DOCKER_REPO}/root-tests:latest-cxx${CXX_STD}
done

cd ../acts-docker
for BUILD_TYPE in ${ACTS_BUILD_TYPES[@]}; do
    echo "***Building ACTS ${BUILD_TYPE} image ***"
    docker build --squash --tag ${DOCKER_REPO}/acts-tests:latest-${BUILD_TYPE} \
                          --build-arg ACTS_BUILD_TYPE=${BUILD_TYPE} .
done

echo "***Building ACTS test framework image ***"
cd ../acts-framework-docker
docker build --squash --tag ${DOCKER_REPO}/acts-framework-tests:latest .

echo "***Building Verrou-enhanced ACTS dev image ***"
cd ../acts-verrou-docker
docker build --squash --tag ${DOCKER_REPO}/acts-verrou-tests:latest .

echo "***Building Gaudi image ***"
cd ../gaudi-docker
docker build --squash --tag ${DOCKER_REPO}/gaudi-tests:latest .

echo "*** Pushing images to the Docker Hub ***"
docker push ${DOCKER_REPO}
