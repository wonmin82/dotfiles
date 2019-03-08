#! /bin/bash

set -e -x

source ./build-env.sh

llvm_tag="llvmorg-7.0.1"

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
stage1_libcxx_include="${stage1_prefix}/src/llvm/libcxx/include"
stage1_clang_include="${stage1_prefix}/src/llvm/clang/include"

mkdir -p ${stage1_src}
pushd ${stage1_src}
git clone https://github.com/llvm/llvm-project.git --no-checkout --depth 1 --single-branch -b ${llvm_tag} $PWD
git checkout ${llvm_tag} -b build
popd

mkdir -p build
pushd build

CC="${stage1_host_gcc_dir}/bin/gcc" \
CXX="${stage1_host_gcc_dir}/bin/g++" \
cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="${install_prefix}" -DCMAKE_BUILD_TYPE="Release" -DLLVM_ENABLE_PROJECTS="all" -DLLVM_BUILD_TOOLS=ON -DLLVM_BUILD_DOCS=ON -DLLVM_ENABLE_DOXYGEN=OFF -DLLVM_ENABLE_SPHINX=OFF -DLLVM_BUILD_LLVM_DYLIB=ON -DLLVM_ENABLE_FFI=ON -DLLVM_ENABLE_RTTI=ON -DCMAKE_CXX_LINK_FLAGS="-L${stage1_host_gcc_dir}/lib64 -Wl,-rpath,${stage1_host_gcc_dir}/lib64" -DLLVM_PARALLEL_COMPILE_JOBS="${jobs}" -DLLVM_PARALLEL_LINK_JOBS="${jobs}" ${stage1_src}/llvm
make -j ${jobs}
make -j ${jobs} install

popd
popd
popd

rm -rf ${build_dir}
