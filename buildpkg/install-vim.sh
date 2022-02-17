#! /usr/bin/env bash

set -e -x

source ./build-env.sh

tag="v8.2.4406"
patch_dir="$PWD/patches/vim"
patch_list=(
	"0001-Temporary-fix-for-man.vim.patch"
)

mkdir ${build_dir}
pushd ${build_dir}

mkdir -p $PWD/vim
pushd $PWD/vim
git clone https://github.com/vim/vim.git \
	--no-checkout --depth 1 --single-branch -b ${tag} $PWD
git checkout refs/tags/${tag} -b build
for p in ${patch_list}; do
	git am ${patch_dir}/$p
done

./configure \
	--target=x86_64-linux-gnu \
	--host=x86_64-linux-gnu \
	--build=x86_64-linux-gnu \
	--prefix=${install_prefix} \
	--with-features=huge \
	--enable-multibyte \
	--enable-rubyinterp \
	--enable-tclinterp \
	--enable-luainterp \
	--enable-perlinterp \
	--enable-python3interp \
	--with-python3-command=python3 \
	--enable-luainterp \
	--enable-gui=no \
	--enable-cscope
make -j ${jobs}
make -j ${jobs} install
popd

popd

rm -r -f ${build_dir}
