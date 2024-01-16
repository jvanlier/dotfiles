#!/usr/bin/env /bin/bash
set -eu

export PY3_VERSION="3.10.13"
export BASE_VENV="base-${PY3_VERSION}"
export TS=$(date +'%Y-%m-%dT%H-%M-%S')
