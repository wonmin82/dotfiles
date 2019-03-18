#! /bin/bash

set -e -x

source ./build-env.sh

tag="v8.1.1017"
patch_dir="$PWD/vim"
patch_list=(
"0001-Temporary-fix-for-man.vim.patch"
)

mkdir ${build_dir}
pushd ${build_dir}

mkdir -p $PWD/vim
pushd $PWD/vim
git clone https://github.com/vim/vim.git --no-checkout --depth 1 --single-branch -b ${tag} $PWD
git checkout refs/tags/${tag} -b build
for p in ${patch_list}; do
	git am ${patch_dir}/$p
done
./configure --target=x86_64-linux-gnu --host=x86_64-linux-gnu --build=x86_64-linux-gnu --prefix=${install_prefix} --with-features=huge --enable-multibyte --enable-rubyinterp --enable-tclinterp --enable-luainterp --enable-pythoninterp --with-python-config-dir=/usr/lib/python2.7/config --enable-perlinterp --enable-luainterp --enable-gui=no --enable-cscope --enable-hangulinput
make -j ${jobs}
make -j ${jobs} install

popd
popd
rm -rf ${build_dir}
