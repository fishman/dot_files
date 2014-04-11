#unless you want the annoying bells or visual bells keep the following 2 lines
xset b off 
xset b 0 0 0 

/usr/X11/bin/xset  fp+ ~/Gentoo/usr/share/fonts/terminus
/usr/X11/bin/xset  fp rehash
# the fork switch won't work on osx, so no -f here
urxvtd -q -o &
