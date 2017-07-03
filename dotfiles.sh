#!/bin/bash

pacman-key --int
pacman-key --populate archlinux

pacman -S cronie

echo "blacklist pcspkr" > /etc/modprobe.d/nobeep.conf
#echo "options cdc_ncm prefer_mbim=N" > /etc/modprobe.d/avoid-mbib.conf


pacman -S keychain
pacman -S tig
pacman -S acpid
pacman -S connman wireless_tools network-manager-applet  gnome-keyring
# 3g
pacman -S gnooki modem-manager-gui
pacman -S iso-codes
pacman -S xorg-server xorg-xdpyinfo xorg-xinit xorg-xset xterm rxvt-unicode xorg-xbacklight xorg-xinput
pacman -S tmux screen
pacman -S libx264 noto-fonts firefox opera qutebrowser qt5-webengine
pacman -S aria2 upower 
pacman -S wget
pacman -S jshon
pacman -S mpd ncmpcpp rtmpdump mpv atomicparsley baka-mplayer beets
pacman -S alsa-utils
pacman -S redshift dunst autocutsel blueman
ln -s /etc/fonts/conf.avail/70-yes-bitmaps.conf /etc/fonts/conf.d
ln -s /etc/fonts/conf.avail/75-yes-terminus.conf /etc/fonts/conf.d

git clone git://github.com/fishman/dot_files.git ~/.dotfiles

wget https://raw.githubusercontent.com/keenerd/packer/master/packer
chmod +x packer
packer -S modem-manager-gui
packer -S keepassxc-git

git clone git://github.com/fishman/awesome-dotfiles ~/.config/awesome
cd ~/.config/awesome
git checkout diff
git submodule update --init

pacman -S luarocks lua-sec
pacman -S the_silver_searcher
packer -S rofi-dmenu

git clone git://github.com/fishman/vim_files.git .vim
ln -s ~/.vim/.vimrc ~/.vimrc

packer -S cmst
gpg --recv-keys 06CA9F5D1DCF2659
packer -S ofono
packer -S connman-ui-git

pacman -S hub

# wakeonlan
pacman -S wol
packer -S ht-editor
pacman -S xsel
pacman -S vagrant
pacman -S qemu qemu-block-iscsi
pacman -S emacs
pacman -S anthy
pacman -S pandoc
pacman -S texlive-core
pacman -S jdk8-openjdk t1utils ghostscript biber ed 
pacman -S ranger doublecmd-gtk2 mc spacefm cabextract
pacman -S highlight atool w3m lua51 p7zip libunrar libcaca
pacman -S cpio lzop unrar
pacman -S openssh
pacman -S openmpi
pacman -S rust go elixir clang r gnuplot
pacman -S nodejs npm
pacman -S ruby
pacman -S rsync

pacman -S python-neovim python2-neovim dos2unix
gem install neovim

git clone https://github.com/arsv/xcubiclight
xorg-xkill xautolock go-tools mercurial
git clone git://github.com/robbyrussell/oh-my-zsh ~/.oh-my-zsh

cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc

git clone git://github.com/syl20bnr/spacemacs ~/.emacs.d
ln -s ~/.dotfiles/emacs/.spacemacs ~/.spacemacs

# dell
pacman -S libsmbios
pacman -S intel-ucode vulkan-intel libva-intel-driver
pacman -S tlp bash-completion ethtool lsb-release smartmontools powertop
packer -S xss-lock i3lock
pacman -S isync offlineimap msmtp mutt
packer -S mu

pacman -S arandr
packer -S autorandr-git
packer -S pidgin pidgin-otr
packer -S calibre zathura-pdf-poppler
packer -S qalculate-gtk-nognome
pacman -S lsof strace htop nethogs iotop
pacman -S ttf-ubuntu-font-family

packer -S light-git

packer -S scrot
packer -S teiler-git copyq imgurbash2

pacman -S wmname
pacman -S fasd

pacman -S erlang-unixodbc lksctp-tools
pacman -S virtualbox libvirt virtualbox-host-dkms virtualbox-ext-oracle rdesktop

pacman -S python-requests python-beautifulsoup4 python-lxml

gpg --recv-keys 1EB2638FF56C0C53

# mimeo
gpg --recv-keys 1D1F0DC78F173680
gpg --recv-keys C43570F80CC295E6
packer -S mimeo xdg-utils-mimeo
packer -S xorg-xprop perl-net-dbus perl-file-mimeinfo

pacman -S gptfdisk ntfs-3g dosfstools exfat-utils

# qt5
pacman -S phonon-qt5-gstreamer oxygen oxygen-icons qt5ct numix-themes feh
pacman -S breeze-icons breeze breeze-gtk cantarell-fonts
pacman -S sddm polkit-qt5 polkit-gnome  lxappearence-gtk  libcanberra
pacman -S xfce4-power-manager

#
packer -S plantuml

## Latex
packer -S latex-mk
packer -S texlive-localmanager-git
pacman -S texlive-bibtexextra

tllocalmgr install wrapfig capt-of glossaries mfirstuc etoolbox xfor datatool substr tracklang titling rfc
texhash

gpasswd -a fishman uucp
gpasswd -a fishman network
newgrp uucp
newgrp network


pacman -S gnome-themes-standard gnome-icon-theme-extras
pacman -S keychain

reflector --verbose -l 200 -n 20 -p http --sort rate --save /etc/pacman.d/mirrorlist

packer -S linux-nvme nvme-cli

packer -S postgresql

USER=`whoami`
gpasswd -a $USER dba
sudo pacman -S udiskie

pacman -S sxiv

# cantarell is terrible for my eyes. ubunt is much better
pacman -S ttf-ubuntu-font-family ttf-dejavu
packer -S ttf-iosevka


##### 
## Media
#####
pacman -S mps-youtube


systemctl enable rfkill-block@bluetooth.service

echo 'kernel.nmi_watchdog = 0' > /etc/sysctl.d/disable_watchdog.conf
echo 'vm.laptop_mode = 5' > /etc/sysctl.d/laptop.conf
pacman -S iptraf-ng

## japanese
pacman -S ibus-kkc ibus-qt ibus-typingbooster ibus-m17n otf-ipafont

pacman -S xdotool pass srm

packer -S rofi-pass passed-git autopass-git

packer -S xdo
