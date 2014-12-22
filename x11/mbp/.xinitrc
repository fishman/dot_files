#!/bin/bash

xrdb ~/.Xresources
xset +fp "${HOME}/.fonts"
echo "disable" > /sys/firmware/acpi/interrupts/gpe66
./.xinitrc-keyboard
redshift&
dunst&
mpd &
conky &
autocutsel -fork &
autocutsel -selection PRIMARY -fork &
/usr/bin/xscreensaver -no-splash &
xset r rate 200 30
syndaemon -t -k -i 2 &
blueman-applet &
xrdb ~/.Xresources
awesome
