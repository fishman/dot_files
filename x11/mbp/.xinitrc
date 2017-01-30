#!/bin/bash
[[ -f ~/.Xresources ]] && xrdb -merge ~/.Xresources
[[ -f ~/.Xdefaults ]] && xrdb -merge ~/.Xdefaults

if [ -z "$XDG_CONFIG_HOME" ]; then
	export XDG_CONFIG_HOME="$HOME/.config"
fi

# Ensure the existance of the 'Desktop' folder
if [ -e "$XDG_CONFIG_HOME/user-dirs.dirs" ]; then
	. "$XDG_CONFIG_HOME/user-dirs.dirs"
else
	XDG_DESKTOP_DIR="$HOME/Desktop"
fi
mkdir -p "$XDG_DESKTOP_DIR"

# Clean up after GDM (GDM sets the number of desktops to one)
xprop -root -remove _NET_NUMBER_OF_DESKTOPS -remove _NET_DESKTOP_NAMES -remove _NET_CURRENT_DESKTOP 2> /dev/null

# Enable GTK+2 integration for OpenOffice.org, if available.
export SAL_USE_VCLPLUGIN=gtk

export RXVT_SOCKET=$HOME/.rxvt_socket

xset +fp /usr/share/fonts/local
xset +fp /usr/share/fonts/TTF
xset +fp /usr/share/fonts/OTF
xset +fp /usr/share/fonts/misc
xset +fp "${HOME}/.fonts"
xset fp rehash

# ./.xinitrc-keyboard
# xset r rate 200 30
systemctl --user set-environment DISPLAY=:0
urxvtd -q -o -f

# echo "disable" > /sys/firmware/acpi/interrupts/gpe66
./.xinitrc-keyboard
dunst&
mpd &
conky &
xmodmap ~/.xmodmap

export XDG_MENU_PREFIX="lxde-"
export XDG_CURRENT_DESKTOP="mimeo"

autocutsel -fork &
autocutsel -selection PRIMARY -fork &
/usr/bin/xscreensaver -no-splash &
xset r rate 200 30
syndaemon -t -k -i 2 &
blueman-applet &
killall xss-lock
xss-lock -- xlock -n &
/usr/bin/lxqt-policykit-agent &
light -S 10
xsetroot -cursor_name left_ptr
rfkill block bluetooth
nm-applet &
[ ! -s ~/.config/mpd/pid ] && mpd
dex -a
awesome
