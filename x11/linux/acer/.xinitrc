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
xset b off
xset b 0 0 0

# xset fp+ /opt/local/gentoo/share/fonts/terminus &
# xset fp rehash &

export BROWSER=firefox
export RXVT_SOCKET=$HOME/.rxvt_socket
urxvtd -q -o -f
autocutsel -fork &
autocutsel -selection PRIMARY -fork &

export BROWSER=mimeo
export GTK_IM_MODULE='uim'
export QT_IM_MODULE='uim'
uim-xim &
export XMODIFIERS=@im='uim'
# xmonad
# xterm
exec ck-launch-session awesome
