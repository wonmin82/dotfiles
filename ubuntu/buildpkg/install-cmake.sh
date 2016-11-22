#!/bin/bash

set -e -x

source ./build-env.sh

version="3.7.0"

mkdir ${build_dir}
pushd ${build_dir}

wget http://www.cmake.org/files/v3.7/cmake-${version}.tar.gz
tar xzpf cmake-${version}.tar.gz
pushd cmake-${version}
./bootstrap --prefix=${install_prefix} --parallel=${jobs}
make -j ${jobs}
make -j ${jobs} install

popd
popd
rm -rf ${build_dir}
