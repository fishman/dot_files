#!/bin/sh

[ -f /tmp/theme ] && read theme < /tmp/theme || theme=$([ $(gsettings get org.gnome.desktop.interface color-scheme) = "'default'" ] && echo "light" || echo "dark")

brightness=$(light -s sysfs/backlight/intel_backlight -G)

jq --unbuffered --compact-output --arg theme ${theme} --arg brightness ${brightness} -n '{"class":$theme, "alt":$theme,"percentage":$brightness|tonumber|floor}'

