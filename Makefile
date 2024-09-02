# Set HAVE_MBEDTLS variable if you want to use MBEDTLS instead of TOMCRYPT
HAVE_MBEDTLS=1
CC=/home/ubuntu/luckfox-pico/tools/linux/toolchain/arm-rockchip830-linux-uclibcgnueabihf/bin/arm-rockchip830-linux-uclibcgnueabihf-gcc
CXX=/home/ubuntu/luckfox-pico/tools/linux/toolchain/arm-rockchip830-linux-uclibcgnueabihf/bin/arm-rockchip830-linux-uclibcgnueabihf-g++
AR=/home/ubuntu/luckfox-pico/tools/linux/toolchain/arm-rockchip830-linux-uclibcgnueabihf/bin/arm-rockchip830-linux-uclibcgnueabihf-ar
LD=/home/ubuntu/luckfox-pico/tools/linux/toolchain/arm-rockchip830-linux-uclibcgnueabihf/bin/arm-rockchip830-linux-uclibcgnueabihf-ld
STRIP=/home/ubuntu/luckfox-pico/tools/linux/toolchain/arm-rockchip830-linux-uclibcgnueabihf/bin/arm-rockchip830-linux-uclibcgnueabihf-strip
SYS_ROOT=/home/ubuntu/luckfox-pico/sysdrv/source/buildroot/buildroot-2023.02.6/output/host/arm-buildroot-linux-uclibcgnueabihf/sysroot

OBJECTS_O = onvif_simple_server.o device_service.o media_service.o ptz_service.o events_service.o fault.o conf.o utils.o log.o ezxml_wrapper.o ezxml/ezxml.o
OBJECTS_N = onvif_notify_server.o conf.o utils.o log.o ezxml_wrapper.o ezxml/ezxml.o
OBJECTS_W = wsd_simple_server.o utils.o log.o ezxml_wrapper.o ezxml/ezxml.o
ifdef HAVE_MBEDTLS
INCLUDE = -DHAVE_MBEDTLS -Iextras/mbedtls/include -ffunction-sections -fdata-sections -lrt
LIBS_O = -Wl,--gc-sections extras/mbedtls/library/libmbedcrypto.a -lpthread -lrt
LIBS_N = -Wl,--gc-sections extras/mbedtls/library/libmbedcrypto.a -lpthread -lrt
else
INCLUDE = -Iextras/libtomcrypt/src/headers -ffunction-sections -fdata-sections -lrt
LIBS_O = -Wl,--gc-sections extras/libtomcrypt/libtomcrypt.a -lpthread -lrt
LIBS_N = -Wl,--gc-sections extras/libtomcrypt/libtomcrypt.a -lpthread -lrt
endif
LIBS_W = -Wl,--gc-sections

ifeq ($(STRIP), )
    STRIP=echo
endif

all: onvif_simple_server onvif_notify_server wsd_simple_server

log.o: log.c $(HEADERS)
	$(CC) -c $< -std=c99 -fPIC -Os $(INCLUDE) -o $@

%.o: %.c $(HEADERS)
	$(CC) -c $< -fPIC -Os $(INCLUDE) -o $@

onvif_simple_server: $(OBJECTS_O)
	$(CC) $(OBJECTS_O) $(LIBS_O) -fPIC -Os -o $@
	$(STRIP) $@

onvif_notify_server: $(OBJECTS_N)
	$(CC) $(OBJECTS_N) $(LIBS_N) -fPIC -Os -o $@
	$(STRIP) $@

wsd_simple_server: $(OBJECTS_W)
	$(CC) $(OBJECTS_W) $(LIBS_W) -fPIC -Os -o $@
	$(STRIP) $@

.PHONY: clean

clean:
	rm -f onvif_simple_server
	rm -f onvif_notify_server
	rm -f wsd_simple_server
	rm -f $(OBJECTS_O)
	rm -f $(OBJECTS_N)
	rm -f $(OBJECTS_W)
