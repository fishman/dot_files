#!/bin/bash

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# merge in defaults and keymaps

if [ -f $sysresources ]; then
    xrdb -merge $sysresources

fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi

if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"

fi

if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi

# start some nice programs
if [ -d /etc/X11/xinit/xinitrc.d ] ; then
    for f in /etc/X11/xinit/xinitrc.d/*; do
        # Do not launch dbus before ConsoleKit (FS#25031)
        #[ -x "$f" ] && . "$f"
        [ "$f" -ne "/etc/X11/xinit/xinitrc.d/30-dbus" ] && [ -x "$f" ] && . "$f"
    done
    unset f
fi

# start some nice programs
xset b off
xset b 0 0 0

# xset +dpms

# xset fp+ /opt/local/gentoo/share/fonts/terminus &
# xset fp rehash &

enable_pulseaudio=0

export BROWSER=firefox
export RXVT_SOCKET=$HOME/.rxvt_socket
export BROWSER=mimeo
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS="@im=fcitx"
export DE=gnome
export OOO_FORCE_DESKTOP=gnome
# export AWT_TOOLKIT=MToolkit
# export _JAVA_AWT_WM_NONREPARENTING=1
export JAVA_FONTS=/usr/share/fonts/TTF
export GDFONTPATH=/usr/share/fonts/TTF
export GDK_NATIVE_WINDOWS=1
export GDK_USE_XFT=1
export GNOME_DESKTOP_SESSION_ID=Default
export ALTERNATE_EDITOR=""
# export _JAVA_OPTIONS='-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel'

# xrandr --dpi 135
# xrandr --dpi 110

if test $enable_pulseaudio = 1; then
	start-pulseaudio-x11
fi
# setxkbmap dvorak
# dex -a
urxvtd -q -o -f
autocutsel -fork
#autocutsel -selection CLIPBOARD -fork
autocutsel -selection PRIMARY -fork
# trayer --edge top --align right --SetDockType true --SetPartialStrut true \
#          --expand true --width 10 --transparent true --tint 0x191970 --height 12 &
remind -z -k"gxmessage -default OK %s" /home/hatori/.reminders &


export GTK2_RC_FILES="$HOME/.gtkrc-2.0"

# to get magnet links going
# gconftool-2 -t string -s /desktop/gnome/url-handlers/magnet/command "/usr/bin/transmission-gtk %s"
# gconftool-2 -s /desktop/gnome/url-handlers/magnet/needs_terminal false -t bool
# gconftool-2 -t bool -s /desktop/gnome/url-handlers/magnet/enabled true
# exec ck-launch-session awesome
# xdg_menu --format awesome --root-menu /etc/xdg/menus/arch-applications.menu >~/.config/awesome/xdg-menu.lua

#/usr/lib/gnome-disk-utility/gdu-notification-daemon &
#nautilus -n &
# xflux -l 53.5559 -g 9.988766 &
# /usr/lib/gnome-settings-daemon/gnome-settings-daemon &
#/usr/lib/gnome-settings-daemon/gnome-fallback-mount-helper &
# gnome-screensaver &
# /usr/bin/gnome-keyring-daemon --start --components=ssh &
# syndaemon -i 0.5 -K -d 
# gnome-sound-applet &
# nm-applet &
# prfkill.py &
# stalonetray &
# trayer --edge top --align right --SetDockType true --SetPartialStrut true --expand true --width 10 --transparent true --alpha 1 --tint 0x1b1d1e --height 24  &
# /usr/lib/notification-daemon-1.0/notification-daemon &

exec ck-launch-session xfce4-session
# exec ck-launch-session awesome
# ck-launch-session gnome-session --session=awesome
# ck-launch-session dbus-launch gnome-session
# ck-launch-session ~/.cabal/bin/xmonad
# awsetbg ~/.config/awesome/themes/81.jpg
# ck-launch-session /usr/bin/xmonad
if test $enable_pulseaudio = 1; then
    pulseaudio --kill
fi
