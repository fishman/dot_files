#!/bin/sh

userresources=$HOME/.xresources
usermodmap=$HOME/.xmodmap
#sysresources=/usr/X11R6/lib/X11/xinit/.Xresources

# merge in defaults and keymaps
#if [ -f $sysresources ]; then
#  xrdb -merge $sysresources
#fi

if [ -f $userresources ]; then
  xrdb -merge $userresources
fi

if [ -f $usermodmap ]; then
  xmodmap $usermodmap
fi

# start some nice programs

#quartz-wm &

xset b off
xset b 0 0 0

xset fp+ /opt/local/gentoo/share/fonts/terminus &
xset fp rehash &

# exec /usr/bin/quartz-wm --only-proxy &
# urxvtd -q -o -f
export RXVT_SOCKET=$HOME/.rxvt_socket
/opt/local/gentoo/usr/bin/urxvtd -q -o &
# exec /usr/bin/quartz-wm 
# cd ~

# xmonad
# xterm
PATH=~/bin:/opt/local/gentoo/usr/bin:$PATH
# /opt/local/gentoo/usr/bin/ratpoison
/opt/local/gentoo/usr/bin/awesome
# quartz-wm
