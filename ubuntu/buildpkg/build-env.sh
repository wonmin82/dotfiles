#!/bin/bash

set -e -x

export jobs="$(grep -c '^processor' /proc/cpuinfo)"
export install_prefix="$HOME/.local"
export build_dir="$PWD/build"

export CFLAGS="-O3"
export CXXFLAGS="-O3"
export LDFLAGS=""
