#! /usr/bin/env bash

list_install_tasks=(
	"server"
	"openssh-server"
	"dns-server"
	"lamp-server"
	"mail-server"
	"postgresql-server"
	"samba-server"
	"kubuntu-desktop"
	"ubuntustudio-graphics"
	"ubuntustudio-audio"
	"ubuntustudio-video"
	"ubuntustudio-photography"
	"ubuntustudio-publishing"
	"ubuntustudio-fonts"
)

list_priority_pkgs=(
	"tasksel"
)

list_uninstall_pkgs=(
)

list_prohibit_pkgs=(
)

list_install_pkgs=(
	"sudo"
	"synaptic"
	"mariadb-server"
	"mariadb-client"
	"postfix"
	"nfs-common"
	"nfs-kernel-server"
	"xscreensaver"
	"xscreensaver-gl"
	"xscreensaver-gl-extra"
	"xscreensaver-data"
	"xscreensaver-data-extra"
	"kile"
	"kbibtex"
	"kscreen"
	"compizconfig-settings-manager"
	"gnome-tweak-tool"
	"kubuntu-restricted-extras"
	"gnome-themes-ubuntu"
	"gnome-themes-standard"
	"hexchat"
	"pidgin"
	"pidgin-nateon"
	"pidgin-plugin-pack"
	"pidgin-themes"
	"vlc"
	"lame"
	"lame-doc"
	"debconf-utils"
	"ubuntu-restricted-extras"
	"libreoffice"
	"fonts-noto"
	"ttf-mscorefonts-installer"
	"build-essential"
	"libboost-all-dev"
	"libboost-doc"
	"man-db"
	"manpages"
	"manpages-dev"
	"manpages-posix"
	"manpages-posix-dev"
	"stl-manual"
	"glibc-doc"
	"glibc-doc-reference"
	"cppman"
	"flex"
	"flex-doc"
	"bison"
	"bison-doc"
	"bisonc++"
	"bisonc++-doc"
	# need to be checked for existence when ubuntu is upgraded {
	"automake"
	"automake1.11"
	# }
	"autotools-dev"
	"autoconf"
	"autopoint"
	"libtool"
	"cmake"
	"cmake-doc"
	"ninja-build"
	"astyle"
	"indent"
	"valgrind"
	"doxygen"
	"graphviz"
	"pandoc"
	"asciidoc"
	"cpp"
	"gcc"
	"g++"
	"gfortran"
	"gobjc"
	"gobjc++"
	"gnat"
	"gdc"
	"cpp-doc"
	"gcc-doc"
	"gfortran-doc"
	"gnat-doc"
	"gcc-multilib"
	"gfortran-multilib"
	"g++-multilib"
	"gobjc++-multilib"
	"gobjc-multilib"
	"gdb"
	"gdb-doc"
	# llvm package list taken from following URL
	# https://packages.ubuntu.com/source/hirsute/llvm-defaults
	# {
	"clang"
	"clang-format"
	"clang-tidy"
	"clang-tools"
	"libc++-dev"
	"libc++1"
	"libc++abi-dev"
	"libc++abi1"
	"libclang-cpp-dev"
	"libclang-dev"
	"libclang1"
	"liblldb-dev"
	"libllvm-ocaml-dev"
	"libomp-dev"
	"libomp5"
	"lld"
	"lldb"
	"llvm"
	"llvm-dev"
	"llvm-runtime"
	"python-clang"
	"python-lldb"
	"python3-clang"
	"python3-lldb"
	# }
	# {
	"libllvm-12-ocaml-dev"
	"libllvm12"
	"llvm-12"
	"llvm-12-dev"
	"llvm-12-doc"
	"llvm-12-examples"
	"llvm-12-runtime"
	"clang-12"
	"clang-tools-12"
	"clang-12-doc"
	"libclang-common-12-dev"
	"libclang-12-dev"
	"libclang1-12"
	"clang-format-12"
	"python3-clang-12"
	"clangd-12"
	"libfuzzer-12-dev"
	"lldb-12"
	"lld-12"
	"libc++-12-dev"
	"libc++abi-12-dev"
	"libomp-12-dev"
	# }
	"php-all-dev"
	"python-all"
	"python-all-dev"
	"python-dev-is-python3"
	"python3-all"
	"python3-dev"
	"python3-all-dev"
	"python3-venv"
	"python3-virtualenv"
	"python3-pip"
	"python3-sphinx"
	"python3-doc"
	"virtualenv"
	"virtualenvwrapper"
	# need to be checked for existence when ubuntu is upgraded {
	"ruby-full"
	"ruby2.7-doc"
	# }
	"rustc"
	"cargo"
	"perl"
	"perl-doc"
	"golang"
	"nodejs"
	"yarn"
	"mono-complete"
	"mono-devel"
	"openjdk-11-jdk"
	"openjdk-11-jre"
	"openjdk-11-jre-headless"
	"openjdk-11-demo"
	"openjdk-11-doc"
	"swig"
	"splint"
	"cppcheck"
	"gettext"
	"dialog"
	"chrpath"
	"colordiff"
	"colormake"
	"colortail"
	"vim"
	"vim-doc"
	"vim-nox"
	"exuberant-ctags"
	"cscope"
	"emacs"
	"ack"
	"zsh"
	"zsh-doc"
	"rdate"
	"inxi"
	"htop"
	"iotop"
	"smem"
	"glances"
	"nmon"
	"tree"
	"mc"
	"tmux"
	"nmap"
	"cvs"
	"subversion"
	"subversion-tools"
	"libapache2-mod-svn"
	"curl"
	"git-all"
	"git-core"
	"git-cvs"
	"git-daemon-sysvinit"
	"git-doc"
	"git-email"
	"git-gui"
	"git-svn"
	"gitk"
	"gitweb"
	"tig"
	"mercurial"
	"vsftpd"
	"lftp"
	"filezilla"
	"moreutils"
	"parallel"
	"axel"
	"aria2"
	"links"
	"links2"
	"lynx"
	"texlive-full"
	"derby-tools"
	"derby-doc"
	"libderby-java"
	"libderbyclient-java"
	"pepperflashplugin-nonfree"
	"gparted"
	"partitionmanager"
	"arj"
	"lhasa"
	"p7zip-full"
	"p7zip-rar"
	"unace-nonfree"
	"unrar"
	"unalz"
	"unixodbc"
	"gperf"
	# need to be checked for existence when ubuntu is upgraded {
	"qttools5-dev-tools"
	"qt5-doc"
	"qtcreator"
	# }
	"libffi-dev"
	"libncurses5"
	"libncurses5-dev"
	"libncursesw5"
	"libncursesw5-dev"
	"e2fslibs-dev"
	"libglib2.0-dev"
	"libgnutls-openssl-dev"
	"libssh2-1-dev"
	"libslang2-dev"
	"libevent-dev"
	"libedit-dev"
	"libcurl4-openssl-dev"
	# build dependency for vim {
	"lua5.2"
	"liblua5.2-dev"
	"tcl8.6"
	"tcl8.6-dev"
	"libperl-dev"
	# }
	"wine-stable"
	"apcalc"
	"hstr"
	"code"
	"google-chrome-stable"
	"docker-ce"
	"docker-ce-cli"
	"containerd.io"
	"docker-compose"
)

list_vm_pkgs=(
	"open-vm-tools"
	"open-vm-tools-desktop"
)

list_install_snap_pkgs=(
	"notepad-plus-plus"
	"shfmt"
)

apt_update="retry aptitude update"
apt_fetch="retry aptitude -y --with-recommends --download-only install"
apt_install="aptitude -y --with-recommends install"
apt_remove="aptitude -y purge"

snap_refresh="snap refresh"
snap_install="snap install"

retry() {
	local nTrys=0
	local maxTrys=50
	local delayBtwnTrys=3
	local lastStatus=256
	until [[ $lastStatus == 0 ]]; do
		$*
		lastStatus=$?
		nTrys=$(($nTrys + 1))
		if [[ $nTrys -gt $maxTrys ]]; then
			echo "Number of re-trys exceeded. Exit code: $lastStatus"
			exit $lastStatus
		fi
		if [[ $lastStatus != 0 ]]; then
			echo "Failed (exit code $lastStatus)... retry count $nTrys/$maxTrys"
			sleep $delayBtwnTrys
		fi
	done
}

gpg_init() {
	export GNUPGHOME=$(echo ~root/.gnupg)

	# Make sure that the /root/.gnupg is exist
	gpg --update-trustdb
}

gpg_get_repo_key() {
	gpg \
		--no-default-keyring \
		--keyring /tmp/archive-keyring.gpg \
		--keyserver hkp://keyserver.ubuntu.com:80 \
		--recv-keys $1
	gpg \
		--no-default-keyring \
		--keyring /tmp/archive-keyring.gpg \
		--output $2 \
		--export $1
	rm -f /tmp/archive-keyring.gpg*
}

pre_process() {
	echo "dash dash/sh boolean false" | debconf-set-selections
	dpkg-reconfigure --frontend noninteractive dash
}

install_apt_prerequisites() {
	eval ${apt_update}
	eval ${apt_fetch} apt-transport-https ca-certificates curl
	eval ${apt_install} apt-transport-https ca-certificates curl
}

add_repo() {
	local flag_nodejs_auto_install=true
	local flag_golang_auto_install=true
	local flag_hstr_auto_install=false

	gpg_init

	add-apt-repository --yes --no-update multiverse

	# remove multiverse from source http://archive.canonical.com/ubuntu
	local buf_src=$(cat /etc/apt/sources.list | grep -e "^deb http://archive.canonical.com/ubuntu" | head -n 1)
	local buf_dst=$(echo ${buf_src} | sed -e "s/ multiverse//")
	sed -e "s#^${buf_src}#${buf_dst}#" -i /etc/apt/sources.list

	# llvm
	curl -sSL --retry 10 --retry-connrefused --retry-delay 3 \
		https://apt.llvm.org/llvm-snapshot.gpg.key |
		gpg --dearmor \
			--output /etc/apt/trusted.gpg.d/llvm-snapshot-archive-keyring.gpg
	LLVM_VERSION="12"
	DISTRO="$(lsb_release -s -c)"
	echo "deb \
		[arch=$(dpkg --print-architecture) \
		signed-by=/etc/apt/trusted.gpg.d/llvm-snapshot-archive-keyring.gpg] \
		http://apt.llvm.org/${DISTRO}/ \
		llvm-toolchain-${DISTRO}-${LLVM_VERSION} main" |
		tee /etc/apt/sources.list.d/llvm.list
	echo "deb-src \
		[arch=$(dpkg --print-architecture) \
		signed-by=/etc/apt/trusted.gpg.d/llvm-snapshot-archive-keyring.gpg] \
		http://apt.llvm.org/${DISTRO}/ \
		llvm-toolchain-${DISTRO}-${LLVM_VERSION} main" |
		tee -a /etc/apt/sources.list.d/llvm.list

	# node.js v12.x
	NODE_VERSION="12.x"
	if [[ ${flag_nodejs_auto_install} == true ]]; then
		# automatic installation
		curl -sSL --retry 10 --retry-connrefused --retry-delay 3 \
			https://deb.nodesource.com/setup_${NODE_VERSION} | bash -
	else
		# manual installation
		curl -sSL --retry 10 --retry-connrefused --retry-delay 3 \
			https://deb.nodesource.com/gpgkey/nodesource.gpg.key |
			gpg --dearmor \
				--output /etc/apt/trusted.gpg.d/nodesource-archive-keyring.gpg
		VERSION="node_${NODE_VERSION}"
		DISTRO="$(lsb_release -s -c)"
		echo "deb \
			[arch=$(dpkg --print-architecture) \
			signed-by=/etc/apt/trusted.gpg.d/nodesource-archive-keyring.gpg] \
			https://deb.nodesource.com/${VERSION} \
			${DISTRO} main" |
			tee /etc/apt/sources.list.d/nodesource.list
		echo "deb-src \
			[arch=$(dpkg --print-architecture) \
			signed-by=/etc/apt/trusted.gpg.d/nodesource-archive-keyring.gpg] \
			https://deb.nodesource.com/${VERSION} \
			${DISTRO} main" |
			tee -a /etc/apt/sources.list.d/nodesource.list
	fi

	# yarn
	curl -sSL --retry 10 --retry-connrefused --retry-delay 3 \
		https://dl.yarnpkg.com/debian/pubkey.gpg |
		gpg --dearmor \
			--output /etc/apt/trusted.gpg.d/yarn-archive-keyring.gpg
	echo "deb \
		[arch=$(dpkg --print-architecture) \
		signed-by=/etc/apt/trusted.gpg.d/yarn-archive-keyring.gpg] \
		https://dl.yarnpkg.com/debian \
		stable main" |
		tee /etc/apt/sources.list.d/yarn.list

	# golang
	if [[ ${flag_golang_auto_install} == true ]]; then
		# automatic installation
		add-apt-repository --yes --no-update \
			ppa:longsleep/golang-backports </dev/null
	else
		# manual installation
		gpg_get_repo_key \
			52B59B1571A79DBC054901C0F6BC817356A3D45E \
			/etc/apt/trusted.gpg.d/golang-backports-archive-keyring.gpg
		DISTRO="$(lsb_release -s -c)"
		echo "deb \
			[arch=$(dpkg --print-architecture) \
			signed-by=/etc/apt/trusted.gpg.d/golang-backports-archive-keyring.gpg] \
			http://ppa.launchpad.net/longsleep/golang-backports/ubuntu \
			${DISTRO} main" |
			tee /etc/apt/sources.list.d/golang-backports.list
	fi

	# mono
	# automatic installation
	gpg_get_repo_key \
		3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF \
		/etc/apt/trusted.gpg.d/mono-archive-keyring.gpg
	DISTRO="focal"
	echo "deb \
		[arch=$(dpkg --print-architecture) \
		signed-by=/etc/apt/trusted.gpg.d/mono-archive-keyring.gpg] \
		https://download.mono-project.com/repo/ubuntu \
		stable-${DISTRO} main" |
		tee /etc/apt/sources.list.d/mono-official-stable.list

	# vscode
	wget -O - https://packages.microsoft.com/keys/microsoft.asc |
		gpg --dearmor --output /etc/apt/trusted.gpg.d/packages.microsoft.gpg
	echo "deb \
		[arch=amd64,arm64,armhf \
		signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] \
		https://packages.microsoft.com/repos/code \
		stable main" |
		tee /etc/apt/sources.list.d/vscode.list

	# google chrome
	wget -O - https://dl-ssl.google.com/linux/linux_signing_key.pub |
		gpg --dearmor --output /etc/apt/trusted.gpg.d/google-chrome-archive-keyring.gpg
	echo "deb \
		[arch=$(dpkg --print-architecture) \
		signed-by=/etc/apt/trusted.gpg.d/google-chrome-archive-keyring.gpg] \
		http://dl.google.com/linux/chrome/deb \
		stable main" |
		tee /etc/apt/sources.list.d/google-chrome.list

	# docker
	# manual installation
	curl -fsSL --retry 10 --retry-connrefused --retry-delay 3 \
		https://download.docker.com/linux/ubuntu/gpg |
		gpg --dearmor \
			--output /etc/apt/trusted.gpg.d/docker-ce-archive-keyring.gpg
	DISTRO="$(lsb_release -s -c)"
	echo "deb \
		[arch=$(dpkg --print-architecture) \
		signed-by=/etc/apt/trusted.gpg.d/docker-ce-archive-keyring.gpg] \
		https://download.docker.com/linux/ubuntu \
		${DISTRO} stable" |
		tee /etc/apt/sources.list.d/docker-ce.list

	# hstr
	if [[ ${flag_hstr_auto_install} == true ]]; then
		# automatic installation
		add-apt-repository --yes --no-update \
			ppa:ultradvorka/ppa </dev/null
	else
		# manual installation
		gpg_get_repo_key \
			1E841C1E5C04D97ABFF8FCB63A9508A2CC6FC1EB \
			/etc/apt/trusted.gpg.d/ultradvorka-archive-keyring.gpg
		DISTRO="focal"
		echo "deb \
			[arch=$(dpkg --print-architecture) \
			signed-by=/etc/apt/trusted.gpg.d/ultradvorka-archive-keyring.gpg] \
			http://ppa.launchpad.net/ultradvorka/ppa/ubuntu \
			${DISTRO} main" |
			tee /etc/apt/sources.list.d/ultradvorka.list
		echo "deb-src \
			[arch=$(dpkg --print-architecture) \
			signed-by=/etc/apt/trusted.gpg.d/ultradvorka-archive-keyring.gpg] \
			http://ppa.launchpad.net/ultradvorka/ppa/ubuntu \
			${DISTRO} main" |
			tee -a /etc/apt/sources.list.d/ultradvorka.list
	fi

	eval ${apt_update}
}

install_priority_packages() {
	eval ${apt_fetch} ${list_priority_pkgs[@]}
	eval ${apt_install} ${list_priority_pkgs[@]}
}

prepare_unattended_install() {
	export DEBIAN_FRONTEND="noninteractive"
	echo "gdm3 shared/default-x-display-manager select gdm3" | debconf-set-selections
	echo "lightdm shared/default-x-display-manager select gdm3" | debconf-set-selections
	echo "sddm shared/default-x-display-manager select gdm3" | debconf-set-selections
	echo "jackd2 jackd/tweak_rt_limits boolean false" | debconf-set-selections
}

install_ttfs() {
	mkdir -p /tmp/msttf
	if [[ -f /tmp/ttf-mscorefonts.tar.xz ]]; then
		tar xvJpf /tmp/ttf-mscorefonts.tar.xz -C /tmp/msttf/
	else
		wget --no-verbose --no-hsts --show-progress --tries=10 \
			--retry-connrefused --directory-prefix=/tmp/msttf \
			http://sourceforge.net/projects/corefonts/files/the%20fonts/final/andale32.exe \
			http://sourceforge.net/projects/corefonts/files/the%20fonts/final/arial32.exe \
			http://sourceforge.net/projects/corefonts/files/the%20fonts/final/arialb32.exe \
			http://sourceforge.net/projects/corefonts/files/the%20fonts/final/comic32.exe \
			http://sourceforge.net/projects/corefonts/files/the%20fonts/final/courie32.exe \
			http://sourceforge.net/projects/corefonts/files/the%20fonts/final/georgi32.exe \
			http://sourceforge.net/projects/corefonts/files/the%20fonts/final/impact32.exe \
			http://sourceforge.net/projects/corefonts/files/the%20fonts/final/times32.exe \
			http://sourceforge.net/projects/corefonts/files/the%20fonts/final/trebuc32.exe \
			http://sourceforge.net/projects/corefonts/files/the%20fonts/final/verdan32.exe \
			http://sourceforge.net/projects/corefonts/files/the%20fonts/final/webdin32.exe
	fi
	chown -v _apt:nogroup /tmp/msttf/*
	chmod -v 644 /tmp/msttf/*
	echo "ttf-mscorefonts-installer msttcorefonts/dldir string /tmp/msttf" | debconf-set-selections
	echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | debconf-set-selections
	aptitude -y install ttf-mscorefonts-installer
	rm -r -f /tmp/msttf
}

fetch_all() {
	for task in "${list_install_tasks[@]}"; do
		list_pkg=($(tasksel --task-packages ${task}))
		eval ${apt_fetch} ${list_pkg[@]}
	done

	eval ${apt_fetch} ${list_install_pkgs[@]}
}

install_all() {
	for task in "${list_install_tasks[@]}"; do
		list_pkg=($(tasksel --task-packages ${task}))
		eval ${apt_install} ${list_pkg[@]}
	done

	if [ ${#list_uninstall_pkgs[@]} -ne 0 ]; then
		eval ${apt_remove} ${list_uninstall_pkgs[@]}
	fi

	eval ${apt_install} ${list_install_pkgs[@]}
}

install_vm_tools() {
	eval ${apt_fetch} ${list_vm_pkgs[@]}
	eval ${apt_install} ${list_vm_pkgs[@]}
}

install_recommended() {
	eval ${apt_fetch} '~RBrecommends:~i'
	eval ${apt_install} '~RBrecommends:~i'
}

install_snap_pkgs() {
	eval ${snap_refresh}
	eval ${snap_install} ${list_install_snap_pkgs[@]}
}

post_process() {
	user="$(id -un 1000)"
	user_root="$(id -un 0)"
	home="$(getent passwd 1000 | cut -d: -f6)"
	home_root="$(getent passwd 0 | cut -d: -f6)"

	# docker
	usermod -aG docker ${user}

	# java
	update-java-alternatives --auto

	sudo -u ${user_root} -H -i dbus-launch --exit-with-session gsettings set org.gnome.settings-daemon.plugins.background active true
	sudo -u ${user_root} -H -i dbus-launch --exit-with-session gsettings reset org.gnome.desktop.background show-desktop-icons

	update-alternatives --set default.plymouth /usr/share/plymouth/themes/bgrt/bgrt.plymouth
	update-grub2
	update-initramfs -k all -u

	if [[ -f ${home}/.config/monitors.xml ]]; then
		cp -f ${home}/.config/monitors.xml /var/lib/gdm3/.config
		chown -v gdm:gdm /var/lib/gdm3/.config/monitors.xml
	fi

	rm -f ${home_root}/.bash_history
	rm -f ${home}/.bash_history

	if [[ -d ${home}/.cache/dconf ]]; then
		chown -R -v ${user}:${user} ${home}/.cache/dconf
	fi

	rm -r -f ${home}/.gvfs || true

	rm -f /usr/bin/gnome-screensaver-command
	ln -s /usr/bin/xscreensaver-command /usr/bin/gnome-screensaver-command

	sudo -u ${user} -H -i bash -c "mkdir -p ${home}/.config/autostart/"

	sudo -u ${user} -H -i bash -c "echo \"[Desktop Entry]\" > ${home}/.config/autostart/xscreensaver.desktop"
	sudo -u ${user} -H -i bash -c "echo \"Type=Application\" >> ${home}/.config/autostart/xscreensaver.desktop"
	sudo -u ${user} -H -i bash -c "echo \"Exec=xscreensaver -nosplash\" >> ${home}/.config/autostart/xscreensaver.desktop"
	sudo -u ${user} -H -i bash -c "echo \"Hidden=false\" >> ${home}/.config/autostart/xscreensaver.desktop"
	sudo -u ${user} -H -i bash -c "echo \"NoDisplay=false\" >> ${home}/.config/autostart/xscreensaver.desktop"
	sudo -u ${user} -H -i bash -c "echo \"X-GNOME-Autostart-enabled=true\" >> ${home}/.config/autostart/xscreensaver.desktop"
	sudo -u ${user} -H -i bash -c "echo \"Name[ko]=XScreenSaver\" >> ${home}/.config/autostart/xscreensaver.desktop"
	sudo -u ${user} -H -i bash -c "echo \"Name=XScreenSaver\" >> ${home}/.config/autostart/xscreensaver.desktop"
	sudo -u ${user} -H -i bash -c "echo \"Comment[ko]=\" >> ${home}/.config/autostart/xscreensaver.desktop"
	sudo -u ${user} -H -i bash -c "echo \"Comment=\" >> ${home}/.config/autostart/xscreensaver.desktop"

	sudo -u ${user} -H -i bash -c "cp -f /usr/share/applications/org.kde.klipper.desktop ${home}/.config/autostart/"
	sudo -u ${user} -H -i bash -c "echo \"X-GNOME-Autostart-enabled=false\" >> ${home}/.config/autostart/org.kde.klipper.desktop"

	rm -r -f ${home}/.zsh_data/antigen ${home}/.zsh_data/antigen-repo
	sudo -u ${user} -H -i zsh -i -c :
}

cleanup_packages() {
	if [[ $(dpkg --get-selections | grep deinstall | cut -f1 | wc -l) != 0 ]]; then
		eval ${apt_remove} $(dpkg --get-selections | grep deinstall | cut -f1)
	fi
	aptitude -y autoclean
}

main() {
	if [[ $EUID -ne 0 ]]; then
		echo "This script must be run as root." 1>&2
		exit 1
	fi

	pre_process
	install_apt_prerequisites
	add_repo
	install_priority_packages
	prepare_unattended_install
	fetch_all
	install_ttfs
	install_all
	install_vm_tools
	# install_recommended
	cleanup_packages
	install_snap_pkgs
	post_process
}

main
