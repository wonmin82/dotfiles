#! /usr/bin/env bash

list_install_tasks=(
	"server"
	"openssh-server"
	"dns-server"
	"lamp-server"
	"mail-server"
	"postgresql-server"
	"samba-server"
	"tomcat-server"
	"virt-host"
	"kubuntu-active"
	"kubuntu-desktop"
	"kubuntu-full"
	"ubuntu-gnome-desktop"
	"ubuntustudio-graphics"
	"ubuntustudio-audio"
	"ubuntustudio-audio-core"
	"ubuntustudio-video"
	"ubuntustudio-photography"
	"ubuntustudio-publishing"
	"ubuntustudio-font-meta"
)

list_priority_pkgs=(
	"tasksel"
)

list_uninstall_pkgs=(
	"gnome-screensaver"
	"qt4-default"
)

list_prohibit_pkgs=(

)

list_install_pkgs=(
	"synaptic"
	"v86d"
	"x11vnc"
	"ubuntu-sdk"
	"mysql-server"
	"phpmyadmin"
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
	"gconf-editor"
	"kubuntu-restricted-extras"
	"gnome-themes-extras"
	"hexchat"
	"pidgin"
	"pidgin-nateon"
	"pidgin-skype"
	"pidgin-plugin-pack"
	"pidgin-themes"
	"amarok"
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
	"universalindentgui"
	"valgrind"
	"doxygen"
	"graphviz"
	"pandoc"
	"asciidoc"
	"cpp"
	"gcc"
	"g++"
	"gfortran"
	"gcj-jdk"
	"gobjc"
	"gobjc++"
	"gnat"
	"gdc"
	"cpp-doc"
	"gcc-doc"
	"gfortran-doc"
	"gnat-doc"
	"libgcj-common"
	"libgcj-bc"
	"gcc-multilib"
	"gfortran-multilib"
	"g++-multilib"
	"gobjc++-multilib"
	"gobjc-multilib"
	"gdb"
	"gdb-doc"
	# need to be checked for existence when ubuntu is upgraded {
	"clang"
	"clang-format"
	"clang-tidy"
	"libclang-dev"
	"libclang1"
	"libllvm-ocaml-dev"
	"lldb"
	"llvm"
	"llvm-dev"
	"llvm-runtime"
	"clang-3.8"
	"clang-3.8-doc"
	"clang-3.8-examples"
	"clang-format-3.8"
	"clang-tidy-3.8"
	"libclang-3.8-dev"
	"libclang-common-3.8-dev"
	"libclang1-3.8"
	"libclang1-3.8-dbg"
	"liblldb-3.8"
	"liblldb-3.8-dbg"
	"liblldb-3.8-dev"
	"libllvm-3.8-ocaml-dev"
	"libllvm3.8"
	"libllvm3.8-dbg"
	"lldb-3.8"
	"lldb-3.8-dev"
	"llvm-3.8"
	"llvm-3.8-dev"
	"llvm-3.8-doc"
	"llvm-3.8-examples"
	"llvm-3.8-runtime"
	"python-clang-3.8"
	"python-lldb-3.8"
	# }
	"php-all-dev"
	"python-all"
	"python-dev"
	"python-all-dev"
	"python-virtualenv"
	"python-pip"
	"python-sphinx"
	"python-doc"
	"python3-all"
	"python3-dev"
	"python3-all-dev"
	"python3-venv"
	"python3-virtualenv"
	"python3-pip"
	"python3-sphinx"
	"python3-doc"
	"flake8"
	"virtualenv"
	"virtualenvwrapper"
	# need to be checked for existence when ubuntu is upgraded {
	"ruby-full"
	"ruby2.3-doc"
	# }
	"rustc"
	"cargo"
	"perl"
	"perl-doc"
	"golang"
	"nodejs"
	"mono-complete"
	"swig"
	"splint"
	"cppcheck"
	"gettext"
	"dialog"
	"chrpath"
	"colordiff"
	"colorgcc"
	"colormake"
	"colortail"
	"vim"
	"vim-doc"
	"vim-gnome"
	"exuberant-ctags"
	"cscope"
	"emacs"
	"ack-grep"
	"zsh"
	"zsh-doc"
	"zsh-lovers"
	"ntp"
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
	"libapache2-svn"
	"git-all"
	"git-arch"
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
	"phpmyadmin"
	"vsftpd"
	"lftp"
	"filezilla"
	"moreutils"
	"axel"
	"aria2"
	"links"
	"links2"
	"lynx-cur"
	"texlive-full"
	"ko.tex-base"
	"ko.tex-extra"
	"ko.tex-extra-hlfont"
	"sun-javadb-client"
	"sun-javadb-common"
	"sun-javadb-core"
	"sun-javadb-demo"
	"sun-javadb-doc"
	"sun-javadb-javadoc"
	"flashplugin-installer"
	"gparted"
	"system-config-lvm"
	"system-config-samba"
	"arj"
	"lhasa"
	"p7zip-full"
	"p7zip-rar"
	"unace-nonfree"
	"unrar"
	"unalz"
	"xserver-xorg-input-vmmouse"
	"curl"
	"unixodbc"
	"gperf"
	# need to be checked for existence when ubuntu is upgraded {
	"qttools5-dev-tools"
	"qt5-default"
	"qt5-doc"
	"qtquick1-5-dev"
	"qtquick1-5-dev-tools"
	"qtcreator"
	"oxideqt-codecs-extra"
	# }
	"libffi-dev"
	"libncurses5"
	"libncurses5-dev"
	"libncursesw5"
	"libncursesw5-dev"
	"e2fslibs-dev"
	"libglib2.0-dev"
	"libgnutls-dev"
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
	"wine"
	"apcalc"
	"hh"
	"docker-engine"
	"docker-compose"
)

list_vm_pkgs=(
	"open-vm-tools"
	"open-vm-tools-desktop"
)

apt_update="retry aptitude update"
apt_fetch="retry aptitude -y --with-recommends --download-only install"
apt_install="aptitude -y --with-recommends install"
apt_remove="aptitude -y purge"

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
	add-apt-repository multiverse

	add-apt-repository ppa:ultradvorka/ppa </dev/null

	# oracle java
	# add-apt-repository ppa:webupd8team/java </dev/null

	# node.js v10.x
	curl -sL --retry 10 --retry-delay 3 \
		https://deb.nodesource.com/setup_10.x | bash -

	# golang
	add-apt-repository ppa:longsleep/golang-backports </dev/null

	# mono
	retry apt-key adv \
		--keyserver hkp://keyserver.ubuntu.com:80 \
		--recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
	echo "deb \
		https://download.mono-project.com/repo/ubuntu \
		stable-xenial \
		main" |
		tee /etc/apt/sources.list.d/mono-official-stable.list

	# docker
	curl -fsSL --retry 10 --retry-delay 3 \
		https://download.docker.com/linux/ubuntu/gpg |
		apt-key add -
	add-apt-repository \
		"deb [arch=amd64] https://download.docker.com/linux/ubuntu \
		$(lsb_release -cs) \
		stable"

	eval ${apt_update}
}

install_priority_packages() {
	eval ${apt_fetch} ${list_priority_pkgs[@]}
	eval ${apt_install} ${list_priority_pkgs[@]}
}

prepare_unattended_install() {
	export DEBIAN_FRONTEND="noninteractive"
	echo "gdm3 shared/default-x-display-manager select lightdm" | debconf-set-selections
	echo "lightdm shared/default-x-display-manager select lightdm" | debconf-set-selections
	echo "sddm shared/default-x-display-manager select lightdm" | debconf-set-selections
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

install_java() {
	ORACLE_JAVA_PKG_PREFIX="oracle-java8"
	eval ${apt_fetch} \
		${ORACLE_JAVA_PKG_PREFIX}-installer \
		${ORACLE_JAVA_PKG_PREFIX}-set-default \
		${ORACLE_JAVA_PKG_PREFIX}-unlimited-jce-policy
	lastStatus=65536
	until [[ ${lastStatus} == 0 ]]; do
		if ((lastStatus != 65536)); then
			eval ${apt_remove} \
				${ORACLE_JAVA_PKG_PREFIX}-installer \
				${ORACLE_JAVA_PKG_PREFIX}-set-default \
				${ORACLE_JAVA_PKG_PREFIX}-unlimited-jce-policy
		fi
		echo "${ORACLE_JAVA_PKG_PREFIX}-installer \
			shared/accepted-oracle-license-v1-1 \
			select true" | debconf-set-selections
		eval ${apt_install} \
			${ORACLE_JAVA_PKG_PREFIX}-installer \
			${ORACLE_JAVA_PKG_PREFIX}-set-default \
			${ORACLE_JAVA_PKG_PREFIX}-unlimited-jce-policy
		lastStatus=$?
	done
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

post_process() {
	user="$(id -un 1000)"
	home="$(getent passwd 1000 | cut -d: -f6)"
	home_root="$(getent passwd 0 | cut -d: -f6)"

	# docker
	usermod -aG docker ${user}

	dbus-launch --exit-with-session gsettings set org.gnome.settings-daemon.plugins.background active true
	dbus-launch --exit-with-session gsettings reset org.gnome.desktop.background show-desktop-icons

	update-alternatives --set default.plymouth /usr/share/plymouth/themes/ubuntu-logo/ubuntu-logo.plymouth
	update-grub2
	update-initramfs -k all -u

	if [[ -f ${home}/.config/monitors.xml ]]; then
		cp -f ${home}/.config/monitors.xml /var/lib/lightdm/.config
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
	# install_java
	install_all
	install_vm_tools
	# install_recommended
	cleanup_packages
	post_process
}

main
