#!/bin/bash

set -e -x

source ./build-env.sh

tag="2.3"

mkdir -p ${build_dir}
pushd ${build_dir}

git clone https://github.com/tmux/tmux.git --no-checkout --depth 1 --single-branch -b ${tag}
pushd tmux
git checkout refs/tags/${tag} -b build
./autogen.sh
./configure --target=x86_64-linux-gnu --host=x86_64-linux-gnu --build=x86_64-linux-gnu --prefix=${install_prefix}
make -j ${jobs}
make -j ${jobs} install

popd
popd
rm -rf ${build_dir}
