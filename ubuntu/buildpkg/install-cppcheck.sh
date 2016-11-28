#!/bin/bash

set -e -x

source ./build-env.sh

tag="1.76.1"

mkdir ${build_dir}
pushd ${build_dir}

git clone https://github.com/danmar/cppcheck.git --no-checkout --depth 1 --single-branch -b ${tag}
pushd cppcheck
git checkout refs/tags/${tag} -b build
make -j ${jobs} SRCDIR=build HAVE_RULES=yes DESTDIR= PREFIX=${install_prefix} CFGDIR=${install_prefix}/share/cppcheck/cfg
make -j ${jobs} SRCDIR=build HAVE_RULES=yes DESTDIR= PREFIX=${install_prefix} CFGDIR=${install_prefix}/share/cppcheck/cfg man
make -j ${jobs} SRCDIR=build HAVE_RULES=yes DESTDIR= PREFIX=${install_prefix} CFGDIR=${install_prefix}/share/cppcheck/cfg install
cp -f -v ./cppcheck.1 ${install_prefix}/share/man/man1

popd
popd
rm -rf ${build_dir}
