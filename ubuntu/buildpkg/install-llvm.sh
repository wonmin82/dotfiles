#!/bin/bash

set -e -x

source ./build-env.sh

llvm_branch="release_39"

mkdir ${build_dir}
pushd ${build_dir}

# stage 1
mkdir -p stage1
pushd stage1

stage1_prefix="$PWD"
stage1_src="${stage1_prefix}/src/llvm"
stage1_host_gcc_dir="$(which gcc | sed -e 's/\/bin\/gcc$//')"
stage1_system_include="/usr/include"
stage1_host_include="${stage1_host_gcc_dir}/include"
stage1_libcxx_include="${stage1_prefix}/src/llvm/projects/libcxx/include"
stage1_clang_include="${stage1_prefix}/src/llvm/tools/clang/include"
stage1_default_includes="${stage1_host_include}:${stage1_system_include}:${stage1_libcxx_include}:${stage1_clang_include}"

mkdir -p ${stage1_src}
pushd ${stage1_src}
git clone http://llvm.org/git/llvm.git --no-checkout --depth 1 --single-branch -b ${llvm_branch} $PWD
git checkout ${llvm_branch} -b build
popd
mkdir -p ${stage1_src}/tools/clang
pushd ${stage1_src}/tools/clang
git clone http://llvm.org/git/clang.git --no-checkout --depth 1 --single-branch -b ${llvm_branch} $PWD
git checkout ${llvm_branch} -b build
popd
mkdir -p ${stage1_src}/tools/clang/tools/extra
pushd ${stage1_src}/tools/clang/tools/extra
git clone http://llvm.org/git/clang-tools-extra.git --no-checkout --depth 1 --single-branch -b ${llvm_branch} $PWD
git checkout ${llvm_branch} -b build
popd
mkdir -p ${stage1_src}/projects/compiler-rt
pushd ${stage1_src}/projects/compiler-rt
git clone http://llvm.org/git/compiler-rt.git --no-checkout --depth 1 --single-branch -b ${llvm_branch} $PWD
git checkout ${llvm_branch} -b build
popd
mkdir -p ${stage1_src}/projects/openmp
pushd ${stage1_src}/projects/openmp
git clone http://llvm.org/git/openmp.git --no-checkout --depth 1 --single-branch -b ${llvm_branch} $PWD
git checkout ${llvm_branch} -b build
popd
mkdir -p ${stage1_src}/projects/libcxx
pushd ${stage1_src}/projects/libcxx
git clone http://llvm.org/git/libcxx.git --no-checkout --depth 1 --single-branch -b ${llvm_branch} $PWD
git checkout ${llvm_branch} -b build
popd
mkdir -p ${stage1_src}/projects/libcxxabi
pushd ${stage1_src}/projects/libcxxabi
git clone http://llvm.org/git/libcxxabi.git --no-checkout --depth 1 --single-branch -b ${llvm_branch} $PWD
git checkout ${llvm_branch} -b build
popd
mkdir -p ${stage1_src}/projects/test-suite
pushd ${stage1_src}/projects/test-suite
git clone http://llvm.org/git/test-suite.git --no-checkout --depth 1 --single-branch -b ${llvm_branch} $PWD
git checkout ${llvm_branch} -b build
popd
mkdir -p ${stage1_src}/lldb
pushd ${stage1_src}/lldb
git clone http://llvm.org/git/lldb.git --no-checkout --depth 1 --single-branch -b ${llvm_branch} $PWD
git checkout ${llvm_branch} -b build
popd
mkdir -p ${stage1_src}/lld
pushd ${stage1_src}/lld
git clone http://llvm.org/git/lld.git --no-checkout --depth 1 --single-branch -b ${llvm_branch} $PWD
git checkout ${llvm_branch} -b build
popd

mkdir -p build
pushd build

CC="${stage1_host_gcc_dir}/bin/gcc" \
CXX="${stage1_host_gcc_dir}/bin/g++" \
cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="${install_prefix}" -DCMAKE_BUILD_TYPE="Release" -DLLVM_BUILD_TOOLS=ON -DLLVM_BUILD_DOCS=ON -DLLVM_ENABLE_DOXYGEN=OFF -DLLVM_ENABLE_SPHINX=ON -DSPHINX_OUTPUT_HTML=OFF -DSPHINX_OUTPUT_MAN=ON -DSPHINX_WARNINGS_AS_ERRORS=OFF -DLLVM_BUILD_LLVM_DYLIB=ON -DLLVM_ENABLE_FFI=ON -DLLVM_ENABLE_RTTI=ON -DGCC_INSTALL_PREFIX="${stage1_host_gcc_dir}" -DC_INCLUDE_DIRS="${stage1_default_includes}" -DCMAKE_CXX_LINK_FLAGS="-L${stage1_host_gcc_dir}/lib64 -Wl,-rpath,${stage1_host_gcc_dir}/lib64" -DLLVM_PARALLEL_COMPILE_JOBS="${jobs}" -DLLVM_PARALLEL_LINK_JOBS="${jobs}" ${stage1_src}
make -j ${jobs}
make -j ${jobs} install

popd
popd
popd

rm -rf ${build_dir}
