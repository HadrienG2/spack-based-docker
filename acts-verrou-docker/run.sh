#!/bin/bash
DIR="$1"
WORKDIR="${ACTS_BUILD_DIR}/Tests/Integration"
valgrind --tool=verrou --rounding-mode=random --demangle=no $WORKDIR/PropagationTests > ${DIR}/results.dat