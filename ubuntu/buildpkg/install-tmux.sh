#!/bin/bash

set -e -x

source ./build-env.sh

branch="2.3"

mkdir -p ${build_dir}
pushd ${build_dir}

git clone https://github.com/tmux/tmux.git --no-checkout --single-branch -b ${branch}
pushd tmux
git checkout ${branch} -b build
./autogen.sh
./configure --target=x86_64-linux-gnu --host=x86_64-linux-gnu --build=x86_64-linux-gnu --prefix=${install_prefix}
make -j ${jobs}
make -j ${jobs} install

popd
popd
rm -rf ${build_dir}
