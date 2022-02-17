#! /usr/bin/env bash

set -e -x

source ./build-env.sh

version="1.21.2"

mkdir ${build_dir}
pushd ${build_dir}

curl -O http://ftp.gnu.org/gnu/wget/wget-${version}.tar.gz
tar xzpf wget-${version}.tar.gz
pushd wget-${version}
./configure --prefix=${install_prefix}
make -j ${jobs}
make -j ${jobs} install
popd

popd

rm -r -f ${build_dir}
