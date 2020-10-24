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
)

export PIP_REQUIRE_VIRTUALENV="false"
pip3 install --user --upgrade pip
pip3 install --user --upgrade ${list_install_python_pkgs[@]}
