#!/bin/bash

# Use this script to build a working example of onvif_simple_server
# This script will compile lighttpd, tls library and the server
# and will prepare a folder with all the files you need.

# If you want to cross-compile to a different platform,
# source your environment here: $CC, $CXX, $STIP, etc...
# and set CROSS_COMPILE_HOST variable

. /home/ubuntu/workspace/onvif_simple_server/env
#CROSS_COMPILE_HOST="--host=arm-openwrt-linux"
CROSS_COMPILE_HOST="--host=arm-rockchip830-linux-uclibcgnueabihf"

INSTALL_DIR="_install"
export HAVE_MBEDTLS=1
LIGHTTPD=lighttpd-1.4.73

# Don't edit below this line

cd ../..
# patch -p0 < onvif_simple_server/extras/path.patch
cd onvif_simple_server/extras

mkdir -p $INSTALL_DIR/bin
mkdir -p $INSTALL_DIR/etc/onvif_notify_server
mkdir -p $INSTALL_DIR/etc/wsd_simple_server
mkdir -p $INSTALL_DIR/lib
mkdir -p $INSTALL_DIR/www/onvif

### LIGHTTPD ###
if [ ! -f lighttpd-1.4.73.tar.gz ]; then
    wget https://download.lighttpd.net/lighttpd/releases-1.4.x/$LIGHTTPD.tar.gz
fi
# tar zxvf $LIGHTTPD.tar.gz
cd $LIGHTTPD

# Run configure with minimal options
./configure $CROSS_COMPILE_HOST CC=$CC CXX=$CXX --disable-ipv6 --without-pcre2 --without-zlib

# make clean
make -j4
cd ..

# Don't use 'make install'
# Copy only essential files
cp $LIGHTTPD/src/lighttpd $INSTALL_DIR/bin
cp $LIGHTTPD/src/.libs/mod_cgi.so $INSTALL_DIR/lib

# Strip binaries
if [ ! -z $STRIP ]; then
    $STRIP $INSTALL_DIR/bin/lighttpd
    $STRIP $INSTALL_DIR/lib/mod_cgi.so
fi

# Create trivial configuration file
echo "server.document-root = \"/usr/local/www/\"" > $INSTALL_DIR/etc/lighttpd.conf
echo "" >> $INSTALL_DIR/etc/lighttpd.conf
echo "server.port = 8080" >> $INSTALL_DIR/etc/lighttpd.conf
echo "" >> $INSTALL_DIR/etc/lighttpd.conf
echo "server.modules = ( \"mod_cgi\" )" >> $INSTALL_DIR/etc/lighttpd.conf
echo "cgi.assign = ( \"_service\" => \"\" )" >> $INSTALL_DIR/etc/lighttpd.conf

### TLS ###
# Build mbedtls or libtomcrypt
if [ "$HAVE_MBEDTLS" == "1" ]; then
    if [ ! -f v3.4.0.tar.gz ]; then
        wget https://github.com/Mbed-TLS/mbedtls/archive/refs/tags/v3.4.0.tar.gz
    fi
    tar zxvf ./v3.4.0.tar.gz
    if [ ! -L mbedtls ]; then
        ln -s mbedtls-3.4.0 mbedtls
    fi
    cp -f mbedtls_config.h mbedtls/include/mbedtls/
    cd mbedtls
    make clean
    make CC=$CC CXX=$CXX CFLAGS="--sysroot=${SYS_ROOT}" LDFLAGS="--sysroot=${SYS_ROOT}" -j4
    cd ..
else
    if [ ! -f crypt-1.18.2.tar.xz ]; then
        wget https://github.com/libtom/libtomcrypt/releases/download/v1.18.2/crypt-1.18.2.tar.xz
    fi
    tar Jxvf ./crypt-1.18.2.tar.xz
    if [ ! -L libtomcrypt ]; then
        ln -s libtomcrypt-1.18.2 libtomcrypt
    fi
    cd libtomcrypt
    # make clean
    CFLAGS="-DLTC_NOTHING -DLTC_SHA1 -DLTC_BASE64" make CC=$CC CXX=$CXX -j4
    cd ..
fi

### ONVIF_SIMPLE_SERVER ###
cd ..
make clean
make
cd extras

cp ../onvif_simple_server $INSTALL_DIR/www/onvif
rm $INSTALL_DIR/www/onvif/device_service
ln -s ./onvif_simple_server $INSTALL_DIR/www/onvif/device_service
rm $INSTALL_DIR/www/onvif/events_service
ln -s ./onvif_simple_server $INSTALL_DIR/www/onvif/events_service
rm $INSTALL_DIR/www/onvif/media_service
ln -s ./onvif_simple_server $INSTALL_DIR/www/onvif/media_service
rm $INSTALL_DIR/www/onvif/ptz_service
ln -s ./onvif_simple_server $INSTALL_DIR/www/onvif/ptz_service
cp -R ../device_service_files $INSTALL_DIR/www/onvif
cp -R ../events_service_files $INSTALL_DIR/www/onvif
cp -R ../generic_files $INSTALL_DIR/www/onvif
cp -R ../media_service_files $INSTALL_DIR/www/onvif
cp -R ../ptz_service_files $INSTALL_DIR/www/onvif

cp ../onvif_notify_server $INSTALL_DIR/bin || exit 1
cp -R ../notify_files/* $INSTALL_DIR/etc/onvif_notify_server

cp ../wsd_simple_server $INSTALL_DIR/bin || exit 1
cp -R ../wsd_files/* $INSTALL_DIR/etc/wsd_simple_server

cp ../onvif_simple_server.conf.example $INSTALL_DIR/etc/onvif_simple_server.conf

# Strip binaries
if [ ! -z $STRIP ]; then
    ${STRIP} $INSTALL_DIR/bin/onvif_notify_server || exit 1
    ${STRIP} $INSTALL_DIR/bin/wsd_simple_server || exit 1
    ${STRIP} $INSTALL_DIR/www/onvif/onvif_simple_server || exit 1
fi
