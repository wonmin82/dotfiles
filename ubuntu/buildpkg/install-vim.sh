#!/bin/bash

set -e -x

source ./build-env.sh

branch="v7.4.1689"

mkdir ${build_dir}
pushd ${build_dir}

git clone https://github.com/vim/vim.git --no-checkout --depth 1 --single-branch -b ${branch}
pushd vim
git checkout ${branch} -b build
./configure --target=x86_64-linux-gnu --host=x86_64-linux-gnu --build=x86_64-linux-gnu --prefix=${install_prefix} --with-features=huge --enable-multibyte --enable-rubyinterp --enable-tclinterp --enable-luainterp --enable-pythoninterp --with-python-config-dir=/usr/lib/python2.7/config --enable-perlinterp --enable-luainterp --enable-gui=no --enable-cscope --enable-hangulinput
make -j ${jobs}
make -j ${jobs} install

popd
popd
rm -rf ${build_dir}
