#! /usr/bin/env bash

set -e -x

source ./build-env.sh

list_install_pkgs=(
	"golang.org/x/tools/gopls@latest"
	"mvdan.cc/sh/v3/cmd/shfmt"
)

for pkg in "${list_install_pkgs[@]}"; do
	GO111MODULE=on go get ${pkg}
done
