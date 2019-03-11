#! /bin/bash

function add_include_path()
{
    include=$1
    shift
    search_paths=$@
    new_includes=${default_includes}

    for p in ${search_paths}; do
        test -d ${p} || continue

        path=`find "${p}" | grep "${include}$" | awk '{print length, $0;}' | sort -n | head -1 | awk '{printf("%s", $2)}'`

        if [ -n "${path}" ]; then
            path=`echo -n ${path} | sed "s#/${include}##g"`
            if [ -n "${new_includes}" ] && ! $(echo "${new_includes}" | tr ":" "\n" | grep -qx "${path}"); then
                new_includes="${new_includes}:${path}"
            else
                new_includes="${new_includes}"
            fi
            break
        fi
    done

    echo -n ${new_includes}
}

set -e -x

source ./build-env.sh

llvm_tag="llvmorg-7.0.1"

triple=$(make -v 2>&1 | grep "^Built for " | sed -e "s/^Built for //")

default_includes=$(add_include_path features.h /usr/include)
default_includes=$(add_include_path sys/cdefs.h /usr/include/${triple} /usr/include)

llvm_srcdir="${build_dir}/src"

common_cflags="-O2"
common_cxxflags="-O2"
common_ldflags=""
common_cmake="-G \"Unix Makefiles\"
-DCMAKE_INSTALL_PREFIX=\"${install_prefix}\"
-DCMAKE_BUILD_TYPE=\"Release\"
-DLLVM_PARALLEL_COMPILE_JOBS=${jobs}
-DLLVM_PARALLEL_LINK_JOBS=${jobs}
-DLLVM_DEFAULT_TARGET_TRIPLE=\"${triple}\"
-DLLVM_HOST_TRIPLE=\"${triple}\"
-DC_INCLUDE_DIRS=\"${default_includes}\"
-DLLVM_ENABLE_PIC=\"on\"
-DLLVM_ENABLE_RTTI=\"off\"
-DLLVM_ENABLE_ASSERTIONS=\"off\"
-DBUILD_SHARED_LIBS=\"on\""

# stage 0
stage0_host_gcc_dir="$(which gcc | sed -e 's/\/bin\/gcc$//')"
stage0_cc="${stage0_host_gcc_dir}/bin/gcc"
stage0_cxx="${stage0_host_gcc_dir}/bin/g++"
stage0_cflags="${common_cflags}"
stage0_cxxflags="${common_cxxflags}"
stage0_ldflags="${common_ldflags}"
stage0_cmake="${common_cmake}
-DCMAKE_C_COMPILER=\"${stage0_cc}\"
-DCMAKE_CXX_COMPILER=\"${stage0_cxx}\"
-DCMAKE_C_FLAGS=\"${stage0_cflags}\"
-DCMAKE_CXX_FLAGS=\"${stage0_cxxflags}\"
-DCMAKE_SHARED_LINKER_FLAGS=\"${stage0_ldflags}\"
-DLLVM_TARGETS_TO_BUILD=\"host\"
-DLLVM_ENABLE_PROJECTS=\"clang\"
-DLLVM_BUILD_TOOLS=\"off\"
-DLLVM_BUILD_DOCS=\"off\"
-DLLVM_ENABLE_DOXYGEN=\"off\"
-DLLVM_ENABLE_SPHINX=\"off\""

# stage 1
stage1_cc="${install_prefix}/bin/clang"
stage1_cxx="${install_prefix}/bin/clang++"
stage1_cflags="${common_cflags}"
stage1_cxxflags="${common_cxxflags}"
stage1_ldflags="${common_ldflags}"
stage1_cmake="${common_cmake}
-DCMAKE_C_COMPILER=\"${stage1_cc}\"
-DCMAKE_CXX_COMPILER=\"${stage1_cxx}\"
-DCMAKE_C_FLAGS=\"${stage1_cflags}\"
-DCMAKE_CXX_FLAGS=\"${stage1_cxxflags}\"
-DCMAKE_SHARED_LINKER_FLAGS=\"${stage1_ldflags}\"
-DLLVM_TARGETS_TO_BUILD=\"host\"
-DLLVM_ENABLE_PROJECTS=\"clang;libcxx;libcxxabi\"
-DLLVM_BUILD_TOOLS=\"off\"
-DLLVM_BUILD_DOCS=\"off\"
-DLLVM_ENABLE_DOXYGEN=\"off\"
-DLLVM_ENABLE_SPHINX=\"off\""

# stage 2
stage2_cc="${install_prefix}/bin/clang"
stage2_cxx="${install_prefix}/bin/clang++"
stage2_cflags="${common_cflags}"
stage2_cxxflags="${common_cxxflags}"
stage2_ldflags="-lstdc++ ${common_ldflags}"
stage2_cmake="${common_cmake}
-DCMAKE_C_COMPILER=\"${stage2_cc}\"
-DCMAKE_CXX_COMPILER=\"${stage2_cxx}\"
-DCMAKE_C_FLAGS=\"${stage2_cflags}\"
-DCMAKE_CXX_FLAGS=\"${stage2_cxxflags}\"
-DCMAKE_SHARED_LINKER_FLAGS=\"${stage2_ldflags}\"
-DLLVM_TARGETS_TO_BUILD=\"all\"
-DLLVM_ENABLE_PROJECTS=\"all\"
-DLLVM_BUILD_TOOLS=\"on\"
-DLLVM_BUILD_DOCS=\"on\"
-DLLVM_ENABLE_DOXYGEN=\"off\"
-DLLVM_ENABLE_SPHINX=\"off\""

mkdir -p ${llvm_srcdir}
pushd ${llvm_srcdir}
git clone https://github.com/llvm/llvm-project.git \
	--no-checkout --depth 1 --single-branch -b ${llvm_tag} \
	$PWD
git checkout ${llvm_tag} -b build
popd

# stage 0
mkdir -p ${build_dir}/stage0
pushd ${build_dir}/stage0

eval cmake ${stage0_cmake} ${llvm_srcdir}/llvm
make -j ${jobs}
make -j ${jobs} install

popd

# stage 1
mkdir -p ${build_dir}/stage1
pushd ${build_dir}/stage1

eval cmake ${stage1_cmake} ${llvm_srcdir}/llvm
make -j ${jobs}
make -j ${jobs} install

popd

# stage 2
mkdir -p ${build_dir}/stage2
pushd ${build_dir}/stage2

eval cmake ${stage2_cmake} ${llvm_srcdir}/llvm
make -j ${jobs}
make -j ${jobs} install

popd

rm -r -f ${build_dir}

exit 0
