#! /usr/bin/env bash

set -e -x

source ./build-env.sh

list_pkgs_go=(
	#+++ list from vim-go
	"github.com/klauspost/asmfmt/cmd/asmfmt@latest"
	"github.com/go-delve/delve/cmd/dlv@latest"
	"github.com/kisielk/errcheck@latest"
	"github.com/davidrjenni/reftools/cmd/fillstruct@master"
	"github.com/rogpeppe/godef@latest"
	"golang.org/x/tools/cmd/goimports@master"
	"golang.org/x/lint/golint@master"
	"golang.org/x/tools/gopls@latest"
	"github.com/golangci/golangci-lint/cmd/golangci-lint@latest"
	"honnef.co/go/tools/cmd/staticcheck@latest"
	"github.com/fatih/gomodifytags@latest"
	"golang.org/x/tools/cmd/gorename@master"
	"github.com/jstemmer/gotags@master"
	"golang.org/x/tools/cmd/guru@master"
	"github.com/josharian/impl@master"
	"honnef.co/go/tools/cmd/keyify@master"
	"github.com/fatih/motion@latest"
	"github.com/koron/iferr@master"
	#--- list from vim-go
	"golang.org/x/tools/cmd/godoc"
	"github.com/sqs/goreturns"
	"golang.org/x/tools/cmd/gotype"
)

list_pkgs_go111=(
	"mvdan.cc/sh/v3/cmd/shfmt"
)

for pkg in "${list_pkgs_go[@]}"; do
	go get -v ${pkg}
done

for pkg in "${list_pkgs_go111[@]}"; do
	GO111MODULE=on go get -v ${pkg}
done
