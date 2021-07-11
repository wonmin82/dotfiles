#! /usr/bin/env bash

set -e -x

source ./build-env.sh

list_install_python_pkgs=(
	"virtualenv"
	"virtualenvwrapper"
	"black"
	"flake8"
	"pep8"
	"autopep8"
	"glances[all]"
	"testresources"
)

export PIP_REQUIRE_VIRTUALENV="false"
python3 -m pip install --user --upgrade --force-reinstall \
	pip
python3 -m pip install --user --upgrade --force-reinstall \
	${list_install_python_pkgs[@]}
