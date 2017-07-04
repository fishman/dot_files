#!/bin/bash

[[ -f ~/.Xresources ]] && xrdb -merge ~/.Xresources
[[ -f ~/.Xdefaults ]] && xrdb -merge ~/.Xdefaults
[[ -f ~/.Xmodmap ]] && xmodmap ~/.Xmodmap

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
xset +fp "${HOME}/.fonts"
xset +fp "${HOME}/.fonts/lokaltog-fixed"
xset +fp "${HOME}/.fonts/lokaltog-symbols"
xset fp rehash

# ./.xinitrc-keyboard
# xset r rate 200 30
systemctl --user set-environment DISPLAY=:0
urxvtd -q -o &
# xautolock -killer "/usr/bin/systemctl hybrid-sleep" -killtime 40 &
# xset dpms 0 60 1800
xautolock -detectsleep -time 2 -locker "${HOME}/bin/xlock" \
  -killer "/usr/bin/systemctl hybrid-sleep" -killtime 40 &
  # -notify 60 -notifier "xset dpms force off" &
killall xss-lock
xss-lock -- "${HOME}/bin/xlock" &
# xinput set-prop 11 "Synaptics Finger" 50 90 255

xinput set-prop 11 "libinput Natural Scrolling Enabled" 1
xinput set-prop 11 "libinput Accel Speed" 1
xinput set-prop 11 "libinput Tapping Enabled" 0


if which dbus-launch >/dev/null && test -z "$DBUS_SESSION_BUS_ADDRESS"; then
	eval "$(dbus-launch --sh-syntax --exit-with-session)"
fi

export XDG_MENU_PREFIX="xfce-"
export XDG_CURRENT_DESKTOP="xfce"
# export XDG_CURRENT_DESKTOP="mimeo"
export VDPAU_DRIVER=va_gl

autocutsel -fork &
# Start the LXDE session
# exec /usr/bin/lxsession -s LXDE -e mimeo

wmstart() {
    # feh  --bg-fill "$HOME/.config/awesome/themes/steamburn/wall.png" 
    # ibus-daemon -drx
    udiskie &
    xcalib ~/colorprofile.icc
    dex -a

    # setxkbmap dvorak -option terminate:ctrl_alt_bkspc -option ctrl:swapcaps
    # setxkbmap dvorak -option terminate:ctrl_alt_bkspc -option ctrl:nocaps

    # wmname LG3D
    # dunst&
    # twmnd &
    # mpd &
    # killall autorandr
    autorandr -c
    #blueman-applet &
    # connman-gtk &
    # xfce4-power-manager &
    /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
    # wicd-gtk &
    # nm-applet &
    # conky &
    ibus-daemon -drx
    xfce4-power-manager
}
dwmrun () {
    dwmstatus &
    while true; do
        $HOME/bin/dwm-status
        sleep 2
    done &
    while true; do
        dwm 2> ~/.dwm.log

        sleep 2
    done
}
[ -e "$SXHKD_FIFO" ] && rm "$SXHKD_FIFO"
mkfifo "$SXHKD_FIFO"
bsp() {
    export PANEL_FIFO=~/.bspwm_fifo
    export PANEL_FIFO_SECOND=~/.bspwm_fifo_2
    # python /usr/lib/python3.4/site-packages/powerline/bindings/bar/powerline-bar.py | ~/bin/lemonbar -u 0 -f 'Terminus for Powerline:size=12,Ionicons:size=12' &
    # stalonetray --icon-size=32 --kludges=force_icons_size -bg '#000000' -geometry 1x1+1280+0 --grow-gravity E --window-layer top &
    feh  --bg-fill "$HOME/.config/awesome/themes/steamburn/wall.png" 
    polybar example&
    blueshift-tray&
    sxhkd -s "$SXHKD_FIFO" &

    autocutsel -fork &
    autocutsel -selection PRIMARY -fork &
    while true; do
      exec bspwm
      sleep 2
    done
  }

# compton -b -c -C -G
xsetroot -cursor_name left_ptr
wmstart
# dwm
bsp
#dwmrun
# setxkbmap dvorak -option terminate:ctrl_alt_bkspc -option ctrl:swapcaps
# exec awesome
killall xss-lock


# redshift-gtk&
# dunst&
# mpd &
# blueman-applet &
# nm-applet &
# conky &
# autocutsel -fork &
# autocutsel -selection PRIMARY -fork &
# /usr/bin/xscreensaver -no-splash &
# syndaemon -t -k -i 0.5 &
