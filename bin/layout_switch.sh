#!/bin/zsh
# https://zuttobenkyou.wordpress.com/2011/05/13/xorg-switching-keyboard-layouts-consistenly-and-reliably-from-userspace/
# LICENSE: PUBLIC DOMAIN
# switch between us, fr, and de layouts

# If an explicit layout is provided as an argument, use it. Otherwise, select the next layout from
# the set [us, fr, de].
OPTIONS=" -option lv3:ralt_switch -option apple:badmap -option ctrl:nocaps -option terminate:ctrl_alt_bksp"
if [[ -n "$1" ]]; then
    setxkbmap $1
else
    layout=$(setxkbmap -query | grep layout | awk '{print $2}')
    case $layout in
        dvorak)
            setxkbmap de -option lv3:ralt_switch -option apple:badmap -option ctrl:nocaps -option terminate:ctrl_alt_bksp
            ;;
        de)
            setxkbmap fr -option lv3:ralt_switch -option apple:badmap -option ctrl:nocaps -option terminate:ctrl_alt_bksp
            ;;
        *)
            setxkbmap dvorak -option lv3:ralt_switch -option apple:badmap -option ctrl:nocaps -option terminate:ctrl_alt_bksp
            ;;
    esac
  fi
