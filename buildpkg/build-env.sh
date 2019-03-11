#! /bin/bash

set -e -x

export install_prefix="$HOME/.local"
export build_dir="$PWD/build"

ncpus="$(getconf _NPROCESSORS_ONLN 2> /dev/null || echo 2)"
jobs="$((ncpus + 1))"
export jobs

export MAKEFLAGS="-j ${jobs}"
export CFLAGS="-O2"
export CXXFLAGS="-O2"
export LDFLAGS=""
