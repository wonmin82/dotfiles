#! /usr/bin/env bash

set -e -x

source ./build-env.sh

curl https://storage.googleapis.com/git-repo-downloads/repo \
	>${install_prefix}/bin/repo
chmod a+x ${install_prefix}/bin/repo
