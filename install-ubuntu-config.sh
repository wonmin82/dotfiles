#! /usr/bin/env bash

scriptfile="$(readlink -f "$0")"
scriptpath="$(readlink -m "$(dirname "${scriptfile}")")"
configspath="${scriptpath}/ubuntu"

flag_superuser=false
flag_force=false

[ ${EUID} == 0 ] && flag_superuser=true
uid=${EUID}
[ ${flag_superuser} == true ] && [ ! -z ${SUDO_USER} ] && uid=${SUDO_UID}
gid=$(id -g ${uid})
home="$(getent passwd ${uid} | cut -f6 -d:)"

root_uid=$(id -u root)
root_gid=$(id -g ${root_uid})
root_home="$(getent passwd ${root_uid} | cut -f6 -d:)"

while [[ $# -gt 0 ]]; do
	case $1 in
	-f | --force)
		flag_force=true
		shift
		;;
	*)
		echo "Unknown option."
		exit 1
		;;
	esac
done

install -v -m 644 -o ${uid} -g ${gid} \
	-D ${configspath}/.bash_aliases -t ${home}/
install -v -m 644 -o ${uid} -g ${gid} \
	-D ${configspath}/.inputrc -t ${home}/
install -v -m 644 -o ${uid} -g ${gid} \
	-D ${configspath}/.tmux.conf -t ${home}/
if [ ! -f ${home}/.gitconfig ] || [ ${flag_force} == true ]; then
	install -v -m 644 -o ${uid} -g ${gid} \
		-D ${configspath}/.gitconfig -t ${home}/
fi
install -v -m 644 -o ${uid} -g ${gid} \
	-D ${configspath}/.clang-format -t ${home}/
install -v -m 644 -o ${uid} -g ${gid} \
	-D ${configspath}/.wgetrc -t ${home}/
install -v -m 644 -o ${uid} -g ${gid} \
	-D ${configspath}/.curlrc -t ${home}/
install -v -m 644 -o ${uid} -g ${gid} \
	-D ${configspath}/.axelrc -t ${home}/
install -v -m 755 -o ${uid} -g ${gid} \
	-d ${home}/.config/
install -v -m 644 -o ${uid} -g ${gid} \
	-D ${configspath}/flake8 -t ${home}/.config/
install -v -m 755 -o ${uid} -g ${gid} \
	-d ${home}/.config/pip/
install -v -m 644 -o ${uid} -g ${gid} \
	-D ${configspath}/pip.conf -t ${home}/.config/pip/
install -v -m 755 -o ${uid} -g ${gid} \
	-d ${home}/.config/python_keyring/
install -v -m 644 -o ${uid} -g ${gid} \
	-D ${configspath}/keyringrc.cfg -t ${home}/.config/python_keyring/
install -v -m 755 -o ${uid} -g ${gid} \
	-d ${home}/.config/fontconfig/
install -v -m 644 -o ${uid} -g ${gid} \
	-D ${configspath}/fonts.conf -t ${home}/.config/fontconfig/

[ ${flag_superuser} == false ] && exit 0

install -v -m 755 -o ${root_uid} -g ${root_gid} \
	-d ${root_home}/.config/pip/
install -v -m 644 -o ${root_uid} -g ${root_gid} \
	-D ${configspath}/pip.conf -t ${root_home}/.config/pip/
install -v -m 755 -o ${root_uid} -g ${root_gid} \
	-d ${root_home}/.config/fontconfig/
install -v -m 644 -o ${root_uid} -g ${root_gid} \
	-D ${configspath}/fonts.conf -t ${root_home}/.config/fontconfig/
install -v -m 644 -o ${root_uid} -g ${root_gid} \
	-D ${configspath}/local.conf -t /etc/fonts/
install -v -m 644 -o ${root_uid} -g ${root_gid} \
	-D ${configspath}/preferences.d/ppa -t /etc/apt/preferences.d/
install -v -m 644 -o ${root_uid} -g ${root_gid} \
	-D ${configspath}/preferences.d/runit -t /etc/apt/preferences.d/
install -v -m 644 -o ${root_uid} -g ${root_gid} \
	-D ${configspath}/preferences.d/docker -t /etc/apt/preferences.d/
install -v -m 644 -o ${root_uid} -g ${root_gid} \
	-D ${configspath}/preferences.d/llvm -t /etc/apt/preferences.d/
install -v -m 644 -o ${root_uid} -g ${root_gid} \
	-D ${configspath}/apt.conf.d/99dpkg-options -t /etc/apt/apt.conf.d/
install -v -m 644 -o ${root_uid} -g ${root_gid} \
	-D ${configspath}/apt.conf.d/99retries -t /etc/apt/apt.conf.d/

exit 0
