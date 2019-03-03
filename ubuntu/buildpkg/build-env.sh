#! /bin/bash

set -e -x

export install_prefix="$HOME/.local"
export build_dir="$PWD/build"

jobs="$(($(grep -c '^processor' /proc/cpuinfo) + 1))"
export jobs

export MAKEFLAGS="-j ${jobs}"
export CFLAGS="-O2"
export CXXFLAGS="-O2"
export LDFLAGS=""
