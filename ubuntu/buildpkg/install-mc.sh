#!/bin/bash

set -e -x

source ./build-env.sh

version="4.8.18"

mkdir ${build_dir}
pushd ${build_dir}

wget http://ftp.midnight-commander.org/mc-${version}.tar.bz2
tar xjpf mc-${version}.tar.bz2
pushd mc-${version}
./configure --target=x86_64-linux-gnu --host=x86_64-linux-gnu --build=x86_64-linux-gnu --prefix=${install_prefix} --enable-vfs-sftp --enable-vfs-undelfs --enable-doxygen-man
make -j ${jobs}
make -j ${jobs} install

popd
popd
rm -rf ${build_dir}
