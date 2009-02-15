#!/bin/sh

# should automatically install cairo
sudo port install pango
sudo port install libconfuse imlib2

wget http://awesome.naquadah.org/download/awesome-2.3.4.tar.bz2
tar xjvf awesome-2.3.4.tar.bz2
cd awesome-2.3.4

patch -p1 < ../awesome.diff

./configure --prefix=/opt/local

# this can probably done much better but meh i have no idea, -i '' means edit in place
sed -i '' -e 's/DEFAULT_CONFIG =.*$/DEFAULT_CONFIG = "\\/' -e 's/-n ".*$//' -e '/./!d' defconfig.h 
