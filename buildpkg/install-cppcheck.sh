#! /usr/bin/env bash

set -e -x

source ./build-env.sh

tag="2.7"

mkdir ${build_dir}
pushd ${build_dir}

mkdir -p $PWD/cppcheck
pushd $PWD/cppcheck
git clone https://github.com/danmar/cppcheck.git \
	--no-checkout --depth 1 --single-branch -b ${tag} $PWD
git checkout refs/tags/${tag} -b build
make -j ${jobs} \
	CXXFLAGS=${CXXFLAGS} \
	MATCHCOMPILER=yes \
	FILESDIR=${install_prefix}/share/cppcheck \
	HAVE_RULES=yes \
	DESTDIR= \
	PREFIX=${install_prefix} \
	CFGDIR=${install_prefix}/share/cppcheck/cfg
make -j ${jobs} \
	CXXFLAGS=${CXXFLAGS} \
	MATCHCOMPILER=yes \
	FILESDIR=${install_prefix}/share/cppcheck \
	HAVE_RULES=yes \
	DESTDIR= \
	PREFIX=${install_prefix} \
	CFGDIR=${install_prefix}/share/cppcheck/cfg \
	man
make -j ${jobs} \
	CXXFLAGS=${CXXFLAGS} \
	MATCHCOMPILER=yes \
	FILESDIR=${install_prefix}/share/cppcheck \
	HAVE_RULES=yes \
	DESTDIR= \
	PREFIX=${install_prefix} \
	CFGDIR=${install_prefix}/share/cppcheck/cfg \
	install
cp -f -v ./cppcheck.1 ${install_prefix}/share/man/man1
popd

popd

rm -r -f ${build_dir}
