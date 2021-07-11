#! /usr/bin/env bash

set -e -x

./install-pythonpkgs.sh
./install-gopkgs.sh
./install-rustup.sh
./install-git.sh
./install-wget.sh
./install-repo.sh
./install-cmake.sh
./install-llvm.sh
./install-cppcheck.sh
./install-vim.sh
./install-tmux.sh
./install-mc.sh
