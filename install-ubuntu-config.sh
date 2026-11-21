#! /usr/bin/env bash

scriptfile="$(readlink -f "$0")"
scriptpath="$(readlink -m "$(dirname "${scriptfile}")")"
source "$scriptpath/lib/install-output.sh" || exit
configspath="${scriptpath}/ubuntu"
commonpath="${scriptpath}/common"

install_config_file() {
	local source_file="$1" directory="$2" owner="$3" group="$4" target action=NEW
	target="${directory%/}/${source_file##*/}"
	if [[ -e "$target" || -L "$target" ]]; then
		action=OVERWRITE
	fi
	install -m 644 -o "$owner" -g "$group" -D "$source_file" -t "$directory" || return
	report_file "$action" "$target"
}

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

install_config_file "$configspath/.bash_aliases" "$home/" "$uid" "$gid"
install_config_file "$configspath/.inputrc" "$home/" "$uid" "$gid"
install_config_file "$commonpath/.tmux.conf" "$home/" "$uid" "$gid"
if [ ! -f "$home/.gitconfig" ] || [ "$flag_force" == true ]; then
	install_config_file "$commonpath/.gitconfig" "$home/" "$uid" "$gid"
else
	report_file SKIP "$home/.gitconfig" 'existing file preserved'
fi
install_config_file "$configspath/.clang-format" "$home/" "$uid" "$gid"
install_config_file "$commonpath/.wgetrc" "$home/" "$uid" "$gid"
install_config_file "$commonpath/.curlrc" "$home/" "$uid" "$gid"
install_config_file "$configspath/.axelrc" "$home/" "$uid" "$gid"
install -m 755 -o "$uid" -g "$gid" -d "$home/.config/"
install_config_file "$commonpath/.config/flake8" "$home/.config/" "$uid" "$gid"
install -m 755 -o "$uid" -g "$gid" -d "$home/.config/pip/"
install_config_file "$commonpath/.config/pip/pip.conf" "$home/.config/pip/" "$uid" "$gid"
install -m 755 -o "$uid" -g "$gid" -d "$home/.config/python_keyring/"
install_config_file "$configspath/keyringrc.cfg" "$home/.config/python_keyring/" "$uid" "$gid"
install -m 755 -o "$uid" -g "$gid" -d "$home/.config/fontconfig/"
install_config_file "$configspath/fonts.conf" "$home/.config/fontconfig/" "$uid" "$gid"

[ ${flag_superuser} == false ] && exit 0

install -m 755 -o "$root_uid" -g "$root_gid" -d "$root_home/.config/pip/"
install_config_file "$commonpath/.config/pip/pip.conf" "$root_home/.config/pip/" "$root_uid" "$root_gid"
install -m 755 -o "$root_uid" -g "$root_gid" -d "$root_home/.config/fontconfig/"
install_config_file "$configspath/fonts.conf" "$root_home/.config/fontconfig/" "$root_uid" "$root_gid"
install_config_file "$configspath/local.conf" /etc/fonts/ "$root_uid" "$root_gid"
install_config_file "$configspath/preferences.d/ppa" /etc/apt/preferences.d/ "$root_uid" "$root_gid"
install_config_file "$configspath/preferences.d/runit" /etc/apt/preferences.d/ "$root_uid" "$root_gid"
install_config_file "$configspath/preferences.d/docker" /etc/apt/preferences.d/ "$root_uid" "$root_gid"
install_config_file "$configspath/preferences.d/llvm" /etc/apt/preferences.d/ "$root_uid" "$root_gid"
install_config_file "$configspath/apt.conf.d/99dpkg-options" /etc/apt/apt.conf.d/ "$root_uid" "$root_gid"
install_config_file "$configspath/apt.conf.d/99retries" /etc/apt/apt.conf.d/ "$root_uid" "$root_gid"

exit 0
