#! /usr/bin/env bash

function add_include_path() {
	include=$1
	shift
	search_paths=$@
	new_includes=${default_includes}

	for p in ${search_paths}; do
		test -d ${p} || continue

		path=$(find "${p}" | grep "${include}$" | awk '{print length, $0;}' | sort -n | head -1 | awk '{printf("%s", $2)}')

		if [ -n "${path}" ]; then
			path=$(echo -n ${path} | sed "s#/${include}##g")
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

llvm_tag="llvmorg-13.0.1"

triple_gcc=$(gcc -v 2>&1 | grep "^Target:" | cut -d ' ' -f 2)
triple_make=$(make -v 2>&1 |
	grep -E "^This program built for |^Built for " |
	sed -e "s/This program built for //" -e "s/^Built for //")

default_includes=$(add_include_path features.h /usr/include)
default_includes=$(add_include_path sys/cdefs.h /usr/include/${triple_gcc} /usr/include)

llvm_srcdir="${build_dir}/llvm-project"
venv_dir="${build_dir}/.venv"

common_cflags="-O2"
common_cxxflags="-O2"
common_ldflags=""
common_cmake="-G \"Ninja\"
-Wno-dev
-DCMAKE_BUILD_TYPE=\"Release\"
-DCMAKE_INSTALL_PREFIX=\"${install_prefix}\"
-DLLVM_LIBDIR_SUFFIX=\"\"
-DLLVM_OCAML_INSTALL_PATH=\"${install_prefix}/lib/ocaml\"
-DLLVM_PARALLEL_COMPILE_JOBS=${jobs}
-DLLVM_PARALLEL_LINK_JOBS=${jobs}
-DLLVM_DEFAULT_TARGET_TRIPLE=\"${triple_make}\"
-DLLVM_HOST_TRIPLE=\"${triple_make}\"
-DC_INCLUDE_DIRS=\"${default_includes}\"
-DLLVM_ENABLE_PIC=\"on\"
-DLLVM_ENABLE_RTTI=\"on\"
-DLLVM_ENABLE_WARNINGS=\"off\"
-DLLVM_ENABLE_ASSERTIONS=\"off\"
-DBUILD_SHARED_LIBS=\"on\"
-DPYTHON_EXECUTABLE:FILEPATH=\"${venv_dir}/bin/python\"
"

# stage 0
stage0_host_gcc_dir="$(which gcc | sed -e 's/\/bin\/gcc$//')"
stage0_cc="${stage0_host_gcc_dir}/bin/gcc"
stage0_cxx="${stage0_host_gcc_dir}/bin/g++"
stage0_cflags="${common_cflags}"
stage0_cxxflags="${common_cxxflags}"
stage0_ldflags="${common_ldflags}"
stage0_projects="clang"
stage0_cmake="${common_cmake}
-DCMAKE_C_COMPILER=\"${stage0_cc}\"
-DCMAKE_CXX_COMPILER=\"${stage0_cxx}\"
-DCMAKE_C_FLAGS=\"${stage0_cflags}\"
-DCMAKE_CXX_FLAGS=\"${stage0_cxxflags}\"
-DCMAKE_EXE_LINKER_FLAGS=\"${stage0_ldflags}\"
-DCMAKE_SHARED_LINKER_FLAGS=\"${stage0_ldflags}\"
-DLLVM_TARGETS_TO_BUILD=\"host\"
-DLLVM_ENABLE_PROJECTS=\"${stage0_projects}\"
-DLLVM_BUILD_TOOLS=\"off\"
-DLLVM_BUILD_DOCS=\"off\"
-DLLVM_ENABLE_OCAMLDOC=\"off\"
-DLLVM_ENABLE_DOXYGEN=\"off\"
-DLLVM_ENABLE_SPHINX=\"off\"
"

# stage 1
stage1_cc="${install_prefix}/bin/clang"
stage1_cxx="${install_prefix}/bin/clang++"
stage1_cflags="${common_cflags}"
stage1_cxxflags="${common_cxxflags}"
stage1_ldflags="${common_ldflags}"
stage1_projects="clang;libcxx;libcxxabi;lld"
stage1_cmake="${common_cmake}
-DCMAKE_C_COMPILER=\"${stage1_cc}\"
-DCMAKE_CXX_COMPILER=\"${stage1_cxx}\"
-DCMAKE_C_FLAGS=\"${stage1_cflags}\"
-DCMAKE_CXX_FLAGS=\"${stage1_cxxflags}\"
-DCMAKE_EXE_LINKER_FLAGS=\"${stage1_ldflags}\"
-DCMAKE_SHARED_LINKER_FLAGS=\"${stage1_ldflags}\"
-DLLVM_TARGETS_TO_BUILD=\"host\"
-DLLVM_ENABLE_PROJECTS=\"${stage1_projects}\"
-DLLVM_BUILD_TOOLS=\"off\"
-DLLVM_BUILD_DOCS=\"off\"
-DLLVM_ENABLE_OCAMLDOC=\"off\"
-DLLVM_ENABLE_DOXYGEN=\"off\"
-DLLVM_ENABLE_SPHINX=\"off\"
"

# stage 2
stage2_cc="${install_prefix}/bin/clang"
stage2_cxx="${install_prefix}/bin/clang++"
stage2_ld="${install_prefix}/bin/ld.lld"
stage2_cflags="${common_cflags}"
stage2_cxxflags="${common_cxxflags} -stdlib=libc++"
stage2_ldflags="${common_ldflags} -stdlib=libc++ -lc++abi"
# stage2_projects="all"
# Full list for llvm 11.0.0
# stage2_projects="clang;clang-tools-extra;compiler-rt;debuginfo-tests;libc;libclc;libcxx;libcxxabi;libunwind;lld;lldb;llgo;mlir;openmp;parallel-libs;polly;pstl"
stage2_projects="clang;clang-tools-extra;compiler-rt;debuginfo-tests;libclc;libcxx;libcxxabi;libunwind;lld;lldb;openmp;parallel-libs;polly;pstl"
stage2_cmake="${common_cmake}
-DCMAKE_C_COMPILER=\"${stage2_cc}\"
-DCMAKE_CXX_COMPILER=\"${stage2_cxx}\"
-DCMAKE_LINKER=\"${stage2_ld}\"
-DCMAKE_C_FLAGS=\"${stage2_cflags}\"
-DCMAKE_CXX_FLAGS=\"${stage2_cxxflags}\"
-DCMAKE_C_LINK_FLAGS=\"-fuse-ld=lld\"
-DCMAKE_CXX_LINK_FLAGS=\"-fuse-ld=lld\"
-DCMAKE_EXE_LINKER_FLAGS=\"${stage2_ldflags}\"
-DCMAKE_SHARED_LINKER_FLAGS=\"${stage2_ldflags}\"
-DLLVM_TARGETS_TO_BUILD=\"all\"
-DLLVM_ENABLE_PROJECTS=\"${stage2_projects}\"
-DLLVM_ENABLE_LIBCXX=\"on\"
-DCLANG_DEFAULT_CXX_STDLIB=\"libc++\"
-DLIBCXX_CXX_ABI=\"libcxxabi\"
-DLIBCXX_CXX_ABI_INCLUDE_PATHS=\"${install_prefix}/include/c++/v1\"
-DLIBCXX_CXX_ABI_LIBRARY_PATH=\"${install_prefix}/lib\"
-DLIBCXXABI_USE_LLVM_UNWINDER=\"on\"
-DLLVM_BUILD_TOOLS=\"on\"
-DLLVM_BUILD_DOCS=\"on\"
-DLLVM_ENABLE_OCAMLDOC=\"off\"
-DLLVM_ENABLE_DOXYGEN=\"off\"
-DLLVM_ENABLE_SPHINX=\"on\"
-DSPHINX_OUTPUT_HTML=\"off\"
-DSPHINX_OUTPUT_MAN=\"on\"
-DSPHINX_WARNINGS_AS_ERRORS=\"off\"
"

unset LD_LIBRARY_PATH

if command -v python3; then
	python_command=python3
else
	python_command=python
fi

mkdir -p ${build_dir}
pushd ${build_dir}

mkdir -p ${llvm_srcdir}
pushd ${llvm_srcdir}
git clone https://github.com/llvm/llvm-project.git \
	--no-checkout --depth 1 --single-branch -b ${llvm_tag} \
	$PWD
git checkout refs/tags/${llvm_tag} -b build
popd

pushd ${llvm_srcdir}
# Workaround for llvm 10~13 build problem
git am ${scriptpath}/patches/llvm/0001-Move-the-definition-of-current_pos.patch
popd

virtualenv -p ${python_command} ${venv_dir}
source ${venv_dir}/bin/activate
python3 -m pip install --upgrade \
	pip
python3 -m pip install --upgrade \
	sphinx sphinx-automodapi recommonmark pygments pyyaml z3-solver

# stage 0
mkdir -p ${build_dir}/stage0
pushd ${build_dir}/stage0

eval cmake ${stage0_cmake} ${llvm_srcdir}/llvm
cmake --build $PWD -- -j ${jobs}
cmake --build $PWD --target install -- -j ${jobs}

popd

# stage 1
mkdir -p ${build_dir}/stage1
pushd ${build_dir}/stage1

eval cmake ${stage1_cmake} ${llvm_srcdir}/llvm
cmake --build $PWD -- -j ${jobs}
cmake --build $PWD --target install -- -j ${jobs}

popd

# stage 2
mkdir -p ${build_dir}/stage2
pushd ${build_dir}/stage2

eval cmake ${stage2_cmake} ${llvm_srcdir}/llvm
cmake --build $PWD -- -j ${jobs}
cmake --build $PWD --target install -- -j ${jobs}

popd

deactivate

popd

rm -r -f ${build_dir}

exit 0
