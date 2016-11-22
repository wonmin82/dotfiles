#!/bin/bash

set -e -x

source ./build-env.sh

version="1.76.1"

mkdir ${build_dir}
pushd ${build_dir}

wget http://sourceforge.net/projects/cppcheck/files/cppcheck/${version}/cppcheck-${version}.tar.bz2
tar xjpf cppcheck-${version}.tar.bz2
pushd cppcheck-${version}
make -j ${jobs} SRCDIR=build HAVE_RULES=yes DESTDIR= PREFIX=${install_prefix} CFGDIR=${install_prefix}/share/cppcheck/cfg
make -j ${jobs} SRCDIR=build HAVE_RULES=yes DESTDIR= PREFIX=${install_prefix} CFGDIR=${install_prefix}/share/cppcheck/cfg man
make -j ${jobs} SRCDIR=build HAVE_RULES=yes DESTDIR= PREFIX=${install_prefix} CFGDIR=${install_prefix}/share/cppcheck/cfg install
cp -f -v ./cppcheck.1 ${install_prefix}/share/man/man1

popd
popd
rm -rf ${build_dir}
