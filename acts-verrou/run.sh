#!/bin/bash
OUTPUT_DIR="$1"
TEST="${ACTS_BUILD_DIR}/Tests/Core/Tools/SurfaceArrayCreatorTests"
valgrind --tool=verrou --rounding-mode=random --demangle=no ${TEST} > ${OUTPUT_DIR}/results.dat