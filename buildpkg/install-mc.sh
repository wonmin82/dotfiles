#! /usr/bin/env bash

set -e -x

source ./build-env.sh

tag="4.8.27"

mkdir ${build_dir}
pushd ${build_dir}

mkdir -p $PWD/mc
pushd $PWD/mc
git clone https://github.com/MidnightCommander/mc.git \
	--no-checkout --depth 1 --single-branch -b ${tag} $PWD
git checkout refs/tags/${tag} -b build
./autogen.sh
./configure \
	--target=x86_64-linux-gnu \
	--host=x86_64-linux-gnu \
	--build=x86_64-linux-gnu \
	--prefix=${install_prefix} \
	--enable-vfs-sftp \
	--enable-vfs-undelfs \
	--enable-doxygen-man
make -j ${jobs}
make -j ${jobs} install
popd

popd

rm -r -f ${build_dir}
