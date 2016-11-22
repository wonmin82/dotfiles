#!/bin/bash

set -e -x

source ./build-env.sh

version="1.18"

mkdir ${build_dir}
pushd ${build_dir}

curl -O http://ftp.gnu.org/gnu/wget/wget-${version}.tar.xz
tar xJpf wget-${version}.tar.xz
pushd wget-${version}
./configure --prefix=${install_prefix}
make -j ${jobs}
make -j ${jobs} install

popd
popd
rm -rf ${build_dir}
