#!/bin/bash
OUTPUT_DIR="$1"

# These tests are excluded beceause they either take too long or freeze
# indefinitely when run in verrou without any active exclusion rule.
EXCLUDE_REGEX="^(SolenoidBField|MaterialCollection|Extrapolator|LoopProtection)"

cd ${ACTS_BUILD_DIR}
valgrind --tool=verrou                                                         \
         --rounding-mode=farthest                                              \
         --demangle=no                                                         \
         --trace-children=yes                                                  \
         ctest -j8 -E ${EXCLUDE_REGEX}                                         \
         > ${OUTPUT_DIR}/results.dat