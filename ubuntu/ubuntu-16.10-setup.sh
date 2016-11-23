#!/bin/bash

list_tasks_to_be_installed=(
"server"
"openssh-server"
"dns-server"
"lamp-server"
"mail-server"
"postgresql-server"
"print-server"
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

list_pkgs_to_be_uninstalled=(
"gnome-screensaver"
"qt4-default"
)

list_pkgs_to_be_prohibited=(

)

list_pkgs_to_be_installed=(
"v86d"
"x11vnc"
"ubuntu-sdk"
"ecryptfs-utils"
"iproute-doc"
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
"gnome-themes-extras"
"pidgin"
"pidgin-nateon"
"pidgin-skype"
"pidgin-plugin-pack"
"pidgin-themes"
"amarok"
"vlc"
"lame"
"lame-doc"
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
"libgnutls-dev"
"libssh2-1-dev"
"libslang2-dev"
"libevent-dev"
"manpages"
"manpages-dev"
"manpages-posix"
"manpages-posix-dev"
"stl-manual"
"glibc-doc"
"glibc-doc-reference"
"c-cpp-reference"
"cppreference-doc-en-html"
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
"sphinx-common"
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
# need to be checked for existence when ubuntu is upgraded {
"llvm"
"llvm-3.9"
"llvm-dev"
"llvm-3.9-dev"
"llvm-3.9-tools"
"llvm-3.9-doc"
"llvm-3.9-examples"
"clang"
"clang-3.9"
"clang-format"
"clang-format-3.9"
"clang-tidy"
"clang-tidy-3.9"
"clang-include-fixer-3.9"
"clang-3.9-doc"
"clang-3.9-examples"
"libclang1"
"libclang-dev"
"libc++1"
"libc++-dev"
"libc++-helpers"
"libclang-3.9-dev"
"libclang-common-3.9-dev"
"libclang1-3.9"
"lldb"
"lldb-3.9"
"liblldb-3.9"
"liblldb-3.9-dev"
"python-clang-3.9"
# }
"splint"
"cppcheck"
"gettext"
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
"git-daemon-run"
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
"libcurl4-openssl-dev"
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
"php-all-dev"
"python-all"
"python-dev"
"python-all-dev"
"python-doc"
"python-flake8"
"python3-all"
"python3-dev"
"python3-all-dev"
"python3-doc"
"python3-flake8"
# need to be checked for existence when ubuntu is upgraded {
"ruby-full"
"ruby2.3-doc"
# }
"rustc"
"cargo"
# lua version should be matched with 'vim --version | grep lua' {
"liblua5.3-dev"
"lua5.3"
# }
"golang"
"nodejs"
"nodejs-legacy"
"npm"
"mono-complete"
"hexchat"
"wine"
"apcalc"
"hh"
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

add_ppa()
{
	# oracle java
	sudo add-apt-repository ppa:webupd8team/java < /dev/null

	sudo add-apt-repository ppa:ultradvorka/ppa < /dev/null

	# mono
	sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
	echo "deb http://download.mono-project.com/repo/debian wheezy main" | sudo tee /etc/apt/sources.list.d/mono-xamarin.list

	retry sudo aptitude update
}

set_preferences()
{
	sudo bash -c 'echo "Package: kaccounts-providers kde-config-telepathy-accounts runit git-daemon-run" > /etc/apt/preferences'
	sudo bash -c 'echo "Pin: release *" >> /etc/apt/preferences'
	sudo bash -c 'echo "Pin-Priority: -99" >> /etc/apt/preferences'
}

install_ttfs()
{
	mkdir -p /tmp/msttf
	wget --no-verbose --show-progress --directory-prefix=/tmp/msttf http://sourceforge.net/projects/corefonts/files/the%20fonts/final/andale32.exe http://sourceforge.net/projects/corefonts/files/the%20fonts/final/arial32.exe http://sourceforge.net/projects/corefonts/files/the%20fonts/final/arialb32.exe http://sourceforge.net/projects/corefonts/files/the%20fonts/final/comic32.exe http://sourceforge.net/projects/corefonts/files/the%20fonts/final/courie32.exe http://sourceforge.net/projects/corefonts/files/the%20fonts/final/georgi32.exe http://sourceforge.net/projects/corefonts/files/the%20fonts/final/impact32.exe http://sourceforge.net/projects/corefonts/files/the%20fonts/final/times32.exe http://sourceforge.net/projects/corefonts/files/the%20fonts/final/trebuc32.exe http://sourceforge.net/projects/corefonts/files/the%20fonts/final/verdan32.exe http://sourceforge.net/projects/corefonts/files/the%20fonts/final/webdin32.exe
	sudo chmod -v 666 /tmp/msttf/*
	echo ttf-mscorefonts-installer msttcorefonts/dldir string /tmp/msttf | sudo debconf-set-selections
	echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | sudo debconf-set-selections
	sudo aptitude -y install ttf-mscorefonts-installer
	rm -rf /tmp/msttf
}

install_java()
{
	ORACLE_JAVA_PKG_PREFIX="oracle-java8"
	retry sudo aptitude -y -d install ${ORACLE_JAVA_PKG_PREFIX}-installer ${ORACLE_JAVA_PKG_PREFIX}-set-default ${ORACLE_JAVA_PKG_PREFIX}-unlimited-jce-policy
	lastStatus=256
	until [[ ${lastStatus} == 0 ]]; do
		sudo aptitude -y purge ${ORACLE_JAVA_PKG_PREFIX}-installer ${ORACLE_JAVA_PKG_PREFIX}-set-default ${ORACLE_JAVA_PKG_PREFIX}-unlimited-jce-policy
		echo ${ORACLE_JAVA_PKG_PREFIX}-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
		sudo aptitude -y install ${ORACLE_JAVA_PKG_PREFIX}-installer ${ORACLE_JAVA_PKG_PREFIX}-set-default ${ORACLE_JAVA_PKG_PREFIX}-unlimited-jce-policy
		lastStatus=$?
	done
}

fetch_all()
{
	aptitude_fetch_command="retry sudo aptitude -y --with-recommends --download-only install"
	for task in "${list_tasks_to_be_installed[@]}"; do
		list_pkg=($(tasksel --task-packages ${task}))
		aptitude_fetch_command="${aptitude_fetch_command} ${list_pkg[@]}"
		eval $aptitude_fetch_command
	done

	aptitude_fetch_command="retry sudo aptitude -y --with-recommends --download-only install"
	aptitude_fetch_command="${aptitude_fetch_command} ${list_pkgs_to_be_installed[@]}"
	eval $aptitude_fetch_command
}

install_all()
{
	aptitude_install_command="sudo aptitude -y --with-recommends install"
	for task in "${list_tasks_to_be_installed[@]}"; do
		list_pkg=($(tasksel --task-packages ${task}))
		aptitude_install_command="${aptitude_install_command} ${list_pkg[@]}"
		eval $aptitude_install_command
	done

	aptitude_remove_command="sudo aptitude -y purge"
	aptitude_remove_command="${aptitude_remove_command} ${list_pkgs_to_be_uninstalled[@]}"
	eval $aptitude_remove_command

	aptitude_install_command="sudo aptitude -y --with-recommends install"
	aptitude_install_command="${aptitude_install_command} ${list_pkgs_to_be_installed[@]}"
	eval $aptitude_install_command
}

install_vm_tools()
{
	aptitude_fetch_command="retry sudo aptitude -y --with-recommends --download-only install"
	aptitude_fetch_command="${aptitude_fetch_command} ${list_vm_pkgs_to_be_installed[@]}"
	eval $aptitude_fetch_command

	aptitude_install_command="sudo aptitude -y --with-recommends install"
	aptitude_install_command="${aptitude_install_command} ${list_vm_pkgs_to_be_installed[@]}"
	eval $aptitude_install_command
}

main()
{
	set_preferences
	add_ppa
	fetch_all
	install_ttfs
	install_java
	install_all
	install_vm_tools
}

main
