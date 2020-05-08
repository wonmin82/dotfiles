#! /usr/bin/env bash

set -e -x

source ./build-env.sh

GO111MODULE=on go get mvdan.cc/sh/v3/cmd/shfmt
