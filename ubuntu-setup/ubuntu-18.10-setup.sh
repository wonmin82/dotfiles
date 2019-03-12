#!/bin/bash

list_tasks_to_be_installed=(
"server"
"openssh-server"
"dns-server"
"lamp-server"
"mail-server"
"postgresql-server"
"samba-server"
"tomcat-server"
"kubuntu-desktop"
"kubuntu-full"
"ubuntustudio-graphics"
"ubuntustudio-audio"
"ubuntustudio-video"
"ubuntustudio-photography"
"ubuntustudio-publishing"
"ubuntustudio-fonts"
)

list_pkgs_priority=(
"tasksel"
"encfs"
"mysql-server"
"phpmyadmin"
"postfix"
"sddm"
)

list_pkgs_to_be_uninstalled=(
"gnome-screensaver"
"qt4-default"
)

list_pkgs_to_be_prohibited=(
)

list_pkgs_to_be_installed=(
"synaptic"
"v86d"
"x11vnc"
"nfs-common"
"nfs-kernel-server"
"ecryptfs-utils"
"libatm1"
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
"gnome-themes-ubuntu"
"gnome-themes-standard"
"pidgin"
"pidgin-nateon"
"pidgin-plugin-pack"
"pidgin-themes"
"amarok"
"vlc"
"lame"
"lame-doc"
"debconf-utils"
"ubuntu-restricted-extras"
"libreoffice"
"ttf-mscorefonts-installer"
"build-essential"
"libboost-all-dev"
"libboost-doc"
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
"manpages"
"manpages-dev"
"manpages-posix"
"manpages-posix-dev"
"stl-manual"
"glibc-doc"
"glibc-doc-reference"
"cppreference-doc-en-html"
"cppreference-doc-en-qch"
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
# need to be checked for existence when ubuntu is upgraded {
"llvm"
"llvm-7"
"llvm-dev"
"llvm-7-dev"
"llvm-7-tools"
"llvm-7-doc"
"llvm-7-examples"
"clang"
"clang-7"
"clang-format"
"clang-format-7"
"clang-tidy"
"clang-tidy-7"
"clang-7-doc"
"clang-7-examples"
"libclang1"
"libclang-dev"
"libc++1"
"libc++-dev"
"libc++-helpers"
"libclang-7-dev"
"libclang-common-7-dev"
"libclang1-7"
"lld"
"lld-7"
"lldb"
"lldb-7"
"liblldb-7"
"liblldb-7-dev"
"python-clang-7"
# }
"swig"
"splint"
"cppcheck"
"gettext"
"chrpath"
"colordiff"
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
"ntp"
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
"phpmyadmin"
"vsftpd"
"lftp"
"filezilla"
"axel"
"aria2"
"links"
"links2"
"lynx"
"texlive-full"
"ko.tex-base"
"ko.tex-extra"
"ko.tex-extra-hlfont"
"derby-tools"
"derby-doc"
"libderby-java"
"libderbyclient-java"
"flashplugin-installer"
"gparted"
"kvpm"
"system-config-samba"
"arj"
"lhasa"
"p7zip-full"
"p7zip-rar"
"unace-nonfree"
"unrar"
"unalz"
"curl"
"libcurl4-openssl-dev"
"unixodbc"
"gperf"
# need to be checked for existence when ubuntu is upgraded {
"qttools5-dev-tools"
"qt5-default"
"qt5-doc"
"qtcreator"
# }
"python-all"
"python-dev"
"python-all-dev"
"python-pip"
"python-sphinx"
"python-pep8"
"python-autopep8"
"python-flake8"
"python-doc"
"python3-all"
"python3-dev"
"python3-all-dev"
"python3-pip"
"python3-sphinx"
"python3-pep8"
"python3-autopep8"
"python3-flake8"
"python3-doc"
"flake8"
# need to be checked for existence when ubuntu is upgraded {
"ruby-full"
"ruby2.5-doc"
# }
"rustc"
"cargo"
# lua version should be matched with 'vim --version | grep lua' {
"liblua5.3-dev"
"lua5.3"
# }
"golang"
"nodejs"
"mono-complete"
"openjdk-11-jdk"
"openjdk-11-jre"
"openjdk-11-jre-headless"
"openjdk-11-demo"
"openjdk-11-doc"
"hexchat"
"wine-stable"
"apcalc"
"docker-ce"
"docker-ce-cli"
"containerd.io"
)

list_vm_pkgs_to_be_installed=(
"open-vm-tools"
"open-vm-tools-desktop"
)

retry()
{
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

pre_process()
{
	echo "dash dash/sh boolean false" | debconf-set-selections
	dpkg-reconfigure --frontend noninteractive dash
}

install_apt_prerequisites()
{
	retry aptitude update
	retry aptitude -y --with-recommends --download-only install apt-transport-https ca-certificates curl
	aptitude -y --with-recommends install apt-transport-https ca-certificates curl
}

add_repo()
{
	add-apt-repository --no-update multiverse

	# oracle java
	add-apt-repository --no-update ppa:webupd8team/java < /dev/null

	# node.js v8.x
	curl -sL --retry 10 --retry-connrefused --retry-delay 3 https://deb.nodesource.com/setup_8.x | bash -

	# mono
	retry apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
	echo "deb https://download.mono-project.com/repo/ubuntu stable-bionic main" | tee /etc/apt/sources.list.d/mono-official-stable.list

	# docker
	curl -fsSL --retry 10 --retry-connrefused --retry-delay 3 https://download.docker.com/linux/ubuntu/gpg | apt-key add -
	sudo add-apt-repository --no-update \
		"deb [arch=amd64] https://download.docker.com/linux/ubuntu \
		$(lsb_release -cs) \
		stable"

	retry aptitude update
}

install_priority_packages()
{
	aptitude_fetch_command="retry aptitude -y --download-only install"
	aptitude_fetch_command="${aptitude_fetch_command} ${list_pkgs_priority[@]}"
	eval $aptitude_fetch_command

	aptitude_install_command="aptitude -y install"
	aptitude_install_command="${aptitude_install_command} ${list_pkgs_priority[@]}"
	eval $aptitude_install_command
}

prepare_unattended_install()
{
	echo "gdm3 shared/default-x-display-manager select gdm3" | debconf-set-selections
	echo "lightdm shared/default-x-display-manager select gdm3" | debconf-set-selections
	echo "sddm shared/default-x-display-manager select gdm3" | debconf-set-selections
	echo "jackd2 jackd/tweak_rt_limits boolean false" | debconf-set-selections
}

install_ttfs()
{
	mkdir -p /tmp/msttf
	if [[ -f /tmp/ttf-mscorefonts.tar.xz ]]; then
		tar xvJpf /tmp/ttf-mscorefonts.tar.xz -C /tmp/msttf/
	else
		wget --no-verbose --no-hsts --show-progress --tries=10 --retry-connrefused --directory-prefix=/tmp/msttf http://sourceforge.net/projects/corefonts/files/the%20fonts/final/andale32.exe http://sourceforge.net/projects/corefonts/files/the%20fonts/final/arial32.exe http://sourceforge.net/projects/corefonts/files/the%20fonts/final/arialb32.exe http://sourceforge.net/projects/corefonts/files/the%20fonts/final/comic32.exe http://sourceforge.net/projects/corefonts/files/the%20fonts/final/courie32.exe http://sourceforge.net/projects/corefonts/files/the%20fonts/final/georgi32.exe http://sourceforge.net/projects/corefonts/files/the%20fonts/final/impact32.exe http://sourceforge.net/projects/corefonts/files/the%20fonts/final/times32.exe http://sourceforge.net/projects/corefonts/files/the%20fonts/final/trebuc32.exe http://sourceforge.net/projects/corefonts/files/the%20fonts/final/verdan32.exe http://sourceforge.net/projects/corefonts/files/the%20fonts/final/webdin32.exe
	fi
	chown -v _apt:nogroup /tmp/msttf/*
	chmod -v 644 /tmp/msttf/*
	echo "ttf-mscorefonts-installer msttcorefonts/dldir string /tmp/msttf" | debconf-set-selections
	echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | debconf-set-selections
	aptitude -y install ttf-mscorefonts-installer
	rm -rf /tmp/msttf
}

install_java()
{
	ORACLE_JAVA_PKG_PREFIX="oracle-java8"
	retry aptitude -y -d install ${ORACLE_JAVA_PKG_PREFIX}-installer ${ORACLE_JAVA_PKG_PREFIX}-set-default ${ORACLE_JAVA_PKG_PREFIX}-unlimited-jce-policy
	lastStatus=256
	until [[ ${lastStatus} == 0 ]]; do
		aptitude -y purge ${ORACLE_JAVA_PKG_PREFIX}-installer ${ORACLE_JAVA_PKG_PREFIX}-set-default ${ORACLE_JAVA_PKG_PREFIX}-unlimited-jce-policy
		echo "${ORACLE_JAVA_PKG_PREFIX}-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections
		aptitude -y install ${ORACLE_JAVA_PKG_PREFIX}-installer ${ORACLE_JAVA_PKG_PREFIX}-set-default ${ORACLE_JAVA_PKG_PREFIX}-unlimited-jce-policy
		lastStatus=$?
	done
}

fetch_all()
{
	aptitude_fetch_command="retry aptitude -y --with-recommends --download-only install"
	for task in "${list_tasks_to_be_installed[@]}"; do
		list_pkg=($(tasksel --task-packages ${task}))
		aptitude_fetch_command="${aptitude_fetch_command} ${list_pkg[@]}"
		eval $aptitude_fetch_command
	done

	aptitude_fetch_command="retry aptitude -y --with-recommends --download-only install"
	aptitude_fetch_command="${aptitude_fetch_command} ${list_pkgs_to_be_installed[@]}"
	eval $aptitude_fetch_command
}

install_all()
{
	aptitude_install_command="aptitude -y --with-recommends install"
	for task in "${list_tasks_to_be_installed[@]}"; do
		list_pkg=($(tasksel --task-packages ${task}))
		aptitude_install_command="${aptitude_install_command} ${list_pkg[@]}"
		eval $aptitude_install_command
	done

	aptitude_remove_command="aptitude -y purge"
	aptitude_remove_command="${aptitude_remove_command} ${list_pkgs_to_be_uninstalled[@]}"
	eval $aptitude_remove_command

	aptitude_install_command="aptitude -y --with-recommends install"
	aptitude_install_command="${aptitude_install_command} ${list_pkgs_to_be_installed[@]}"
	eval $aptitude_install_command
}

install_vm_tools()
{
	aptitude_fetch_command="retry aptitude -y --with-recommends --download-only install"
	aptitude_fetch_command="${aptitude_fetch_command} ${list_vm_pkgs_to_be_installed[@]}"
	eval $aptitude_fetch_command

	aptitude_install_command="aptitude -y --with-recommends install"
	aptitude_install_command="${aptitude_install_command} ${list_vm_pkgs_to_be_installed[@]}"
	eval $aptitude_install_command
}

install_recommended()
{
	aptitude_fetch_command="retry aptitude -y --with-recommends --download-only install"
	aptitude_fetch_command="${aptitude_fetch_command} '~RBrecommends:~i'"
	eval $aptitude_fetch_command

	aptitude_install_command="aptitude -y --with-recommends install"
	aptitude_install_command="${aptitude_install_command} '~RBrecommends:~i'"
	eval $aptitude_install_command
}

post_process()
{
	user="$(id -un 1000)"
	home="$(getent passwd 1000 | cut -d: -f6)"
	home_root="$(getent passwd 0 | cut -d: -f6)"

	# docker
	usermod -aG docker ${user}

	# java
	update-java-alternatives --auto

	dbus-launch --exit-with-session gsettings set org.gnome.settings-daemon.plugins.background active true
	dbus-launch --exit-with-session gsettings reset org.gnome.desktop.background show-desktop-icons

	update-alternatives --set default.plymouth /usr/share/plymouth/themes/ubuntu-logo/ubuntu-logo.plymouth
	update-grub2
	update-initramfs -k all -u

	snap refresh

	if [[ -f ${home}/.config/monitors.xml ]]; then
		cp -f ${home}/.config/monitors.xml /var/lib/gdm3/.config
	fi

	rm -f ${home_root}/.bash_history
	rm -f ${home}/.bash_history

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
}

cleanup_packages()
{
	if [[ $(dpkg --get-selections | grep deinstall | cut -f1 | wc -l) != 0 ]]; then
		aptitude -y purge $(dpkg --get-selections | grep deinstall | cut -f1)
	fi
	aptitude -y autoclean
}

main()
{
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
	install_java
	install_all
	install_vm_tools
	install_recommended
	cleanup_packages
	post_process
}

main
