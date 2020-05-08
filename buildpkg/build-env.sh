#! /usr/bin/env bash

set -e -x

scriptfile=$(readlink -f "$0")
scriptpath=$(readlink -m "$(dirname "${scriptfile}")")

export install_prefix="$HOME/.local"
export build_dir="${scriptpath}/build"

ncpus="$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 2)"
jobs="$((ncpus + 1))"
export jobs

export MAKEFLAGS="-j ${jobs}"
export CFLAGS="-O2"
export CXXFLAGS="-O2"
export LDFLAGS=""
