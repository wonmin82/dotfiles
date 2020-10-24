#! /usr/bin/env bash

set -e -x

./install-git.sh
./install-wget.sh
./install-repo.sh
./install-cmake.sh
./install-llvm.sh
./install-cppcheck.sh
./install-vim.sh
./install-tmux.sh
./install-mc.sh
./install-shfmt.sh
./install-pythonpkgs.sh
