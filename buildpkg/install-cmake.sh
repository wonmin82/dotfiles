#! /usr/bin/env bash

set -e -x

source ./build-env.sh

tag="v3.22.2"

mkdir ${build_dir}
pushd ${build_dir}

mkdir -p $PWD/cmake
pushd $PWD/cmake
git clone https://gitlab.kitware.com/cmake/cmake.git \
	--no-checkout --depth 1 --single-branch -b ${tag} $PWD
git checkout refs/tags/${tag} -b build
./bootstrap --prefix=${install_prefix} --parallel=${jobs}
make -j ${jobs}
make -j ${jobs} install
popd

popd

rm -r -f ${build_dir}
