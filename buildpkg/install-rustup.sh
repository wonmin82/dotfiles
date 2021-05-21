#! /usr/bin/env bash

# The rustup and rust will be installed in $HOME/.rustup and $HOME/.cargo

set -e -x

source ./build-env.sh

mkdir -p ${build_dir}
pushd ${build_dir}

mkdir -p $PWD/rustup
pushd $PWD/rustup
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs |
	tee $PWD/rustup-init.sh >/dev/null
chmod a+x $PWD/rustup-init.sh

RUSTUP_INIT_SKIP_PATH_CHECK=yes \
	./rustup-init.sh \
	-y \
	--verbose \
	--default-host x86_64-unknown-linux-gnu \
	--default-toolchain none \
	--no-modify-path
source $HOME/.cargo/env
rustup \
	--verbose \
	toolchain install \
	stable \
	--profile default
popd

popd

rm -r -f ${build_dir}
