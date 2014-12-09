export LANG=en_US.UTF-8
export SHELL=$HOME/Gentoo/bin/zsh
cd ~

source ~/Gentoo/etc/profile
export PATH=/usr/local/bin:~/bin:$PATH:/usr/X11/bin:/usr/texbin
export RXVT_SOCKET=$HOME/.rxvt_socket

#unless you want the annoying bells or visual bells keep the following 2 lines
xset b off 
xset b 0 0 0 

/usr/X11/bin/xset  fp+ ~/Gentoo/usr/share/fonts/terminus
/usr/X11/bin/xset  fp+ ~/Gentoo/usr/share/fonts/corefonts
/usr/X11/bin/xset  fp+ ~/Gentoo/usr/share/fonts/dejavu
/usr/X11/bin/xset  fp+ ~/Gentoo/usr/share/fonts/urw-fonts
/usr/X11/bin/xset  fp rehash
