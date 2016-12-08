#!/bin/bash

set -e -x

source ./build-env.sh

version="2.10.2"

mkdir ${build_dir}
pushd ${build_dir}

curl -O ftp://ftp.kernel.org/pub/software/scm/git/git-${version}.tar.xz
tar xJpf git-${version}.tar.xz
pushd git-${version}
./configure --target=x86_64-linux-gnu --host=x86_64-linux-gnu --build=x86_64-linux-gnu --prefix=${install_prefix}
make -j ${jobs}
make -j ${jobs} man
make -j ${jobs} html
make -j ${jobs} install
make -j ${jobs} install-man
make -j ${jobs} install-html

popd
popd
rm -rf ${build_dir}