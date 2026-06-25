#!/bin/bash
set -eu

export PY3_VERSION="3.14.6"

# Build CPython optimized for this machine (PGO + LTO + native arch).
# Note: -march=native produces a non-portable binary, fine for a personal machine.
export PYTHON_CONFIGURE_OPTS='--enable-optimizations --with-lto' PYTHON_CFLAGS='-march=native -mtune=native'
export PROFILE_TASK='-m test.regrtest --pgo -j0'
TS=$(date +'%Y-%m-%dT%H-%M-%S')
export TS
