#!/bin/sh

set -e
apt update && apt install --yes build-essential libexpat1-dev zlib1g-dev libgmp-dev texinfo patchelf

wget https://ftp.gnu.org/gnu/gdb/gdb-12.1.tar.gz
tar xf gdb-12.1.tar.gz

mkdir gdb-install
mkdir gdb-build
wget https://github.com/indygreg/python-build-standalone/releases/download/20220802/cpython-3.10.6+20220802-x86_64-unknown-linux-gnu-install_only.tar.gz
tar xf cpython-3.10.6+20220802-x86_64-unknown-linux-gnu-install_only.tar.gz -C /root/gdb-install

cd gdb-build

CFLAGS="-I/root/gdb-install/python/include/python3.10" \
LDFLAGS="-L/root/gdb-install/python/lib" \
LIBS="-lpython3" \
../gdb-12.1/configure \
    --enable-targets=aarch64-linux-gnu,arm-linux-gnu,arm-linux-gnueabi,arm-linux-gnueabihf,i686-linux-gnu,mips-linux-gnu,mipsel-linux-gnu,mips64-linux-gnu,mips64el-linux-gnu,x86_64-linux-gnu \
    --disable-gdbserver \
    --disable-sim \
    --enable-multilib \
    --disable-nls \
    --disable-docs \
    --srcdir=/root/gdb-12.1 \
    --with-python=/root/gdb-install/python/bin/python3.10 \
    --with-expat \
    --prefix=/root/gdb-install \
    --with-gdb-datadir=/root/gdb-install/usr/local/share/gdb \
    --without-auto-load-safe-path


LDFLAGS="-L/root/gdb-install/python/lib  -lcrypt -lpthread -ldl -lutil -lm" \
LIBS="-lcrypt -lpthread -ldl  -lutil -lm" \
make
make install
cd ..

wget https://github.com/hugsy/gef/releases/download/2022.06/gef.py -O ./gdb-install/.gdbinit-gef.py
touch ./gdb-install/.gdbinit

cd ./gdb-install/lib
cp /lib/x86_64-linux-gnu/libexpat.so.1 .
cp /usr/lib/x86_64-linux-gnu/libgmp.so.10 .
cp /lib/x86_64-linux-gnu/libgcc_s.so.1 .
cd ../..

patchelf --set-rpath '$ORIGIN/../python/lib/:$ORIGIN/../lib' ./gdb-install/bin/gdb
tar czf gdb-12.1-build.tar.gz -C gdb-install .
