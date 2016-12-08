#!/bin/bash

set -e -x

source ./build-env.sh

tag="v3.7.1"

mkdir ${build_dir}
pushd ${build_dir}

git clone https://gitlab.kitware.com/cmake/cmake.git --no-checkout --depth 1 --single-branch -b ${tag}
pushd cmake
git checkout refs/tags/${tag} -b build
./bootstrap --prefix=${install_prefix} --parallel=${jobs}
make -j ${jobs}
make -j ${jobs} install

popd
popd
rm -rf ${build_dir}