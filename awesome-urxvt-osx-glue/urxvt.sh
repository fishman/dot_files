#!/bin/sh

#ln -s /usr/bin/perl /opt/local/bin/perl5
wget http://dist.schmorp.de/rxvt-unicode/rxvt-unicode-9.06.tar.bz2
tar xjvf rxvt-unicode-9.06.tar.bz2
cd rxvt-unicode-9.06
patch -p1 < doc/urxvt-8.2-256color.patch
patch -p0 < ../rxvtperl-objc-doublefree.diff
./configure --prefix=/opt/local --enable-xterm-colors=256
find . -name Makefile -exec sed -i '' 's/-arch ppc//g' '{}' \;
cd src
sudo make install
cd ../doc
sudo make install

