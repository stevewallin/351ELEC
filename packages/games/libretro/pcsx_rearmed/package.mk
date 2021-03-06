# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020 Trond Haugland (trondah@gmail.com)

PKG_NAME="pcsx_rearmed"
PKG_VERSION="bde5ee93147e22965118455b8397d4b28ed7743d"
PKG_SHA256="69fdb41dd33f4e850279190f3a5e6bcb834e31cb4c3ba5df5329cabc63c860cb"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/libretro/pcsx_rearmed"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_SHORTDESC="ARM optimized PCSX fork"
PKG_TOOLCHAIN="manual"
PKG_BUILD_FLAGS="+speed -gold"

makeinstall_target() {
  cd ${PKG_BUILD}
  if [ "${ARCH}" != "aarch64" ]; then
    make -f Makefile.libretro GIT_VERSION=${PKG_VERSION} platform=rpi3
  fi

# Thanks to escalade for the multilib solution! https://forum.odroid.com/viewtopic.php?f=193&t=39281

VERSION=${LIBREELEC_VERSION}
INSTALLTO="/usr/lib/libretro/"

mkdir -p ${INSTALL}${INSTALLTO}

if [ "${ARCH}" = "aarch64" ]; then
    mkdir -p ${INSTALL}/usr/bin
    mkdir -p ${INSTALL}/usr/lib32
    LIBS="ld-2.*.so \
		libarmmem-v7l.* \
		librt*.so* \
		libass.so* \
		libasound.so* \
		libopenal.so* \
		libpulse.so* \
		libpulseco*.so* \
		libfreetype.so* \
		libpthread*.so* \
		libudev.so* \
		libusb-1.0.so* \
		libSDL2-2.0.so* \
		libavcodec.so* \
		libavformat.so* \
		libavutil.so.56* \
		libswscale.so.5* \
		libswresample.so.3* \
		libstdc++.so.6* \
		libm.so* \
		libm-2.*.so \
		libgcc_s.so* \
		libc.so* \
		libc-*.so \
		ld-linux-armhf.so* \
		libfontconfig.so* \
		libexpat.so* \
		libbz2.so* \
		libz.so* \
		libpulsecommon-12* \
		libdbus-1.so* \
		libdav1d.so* \
		libspeex.so* \
		libssl.so* \
		libcrypt*.so* \
		libsystemd.so* \
		libdl.so.2 \
		libdl-*.so \
		libMali.*.so \
		libdrm.so* \
		librga.so \
		libpng*.so.* \
		librockchip_mpp.so* \
		libxkbcommon.so* \
		libresolv*.so.* \
		libnss_dns-*.so* \
		libpthread.so.* \
		libmali*.so*"

    for lib in ${LIBS}
    do 
      find $PKG_BUILD/../../build.${DISTRO}-${DEVICE}.arm-${VERSION}/*/.install_pkg -name ${lib} -exec cp -vP \{} ${INSTALL}/usr/lib32 \;
    done
    cp -vP $PKG_BUILD/../../build.${DISTRO}-${DEVICE}.arm-${VERSION}/retroarch-*/.install_pkg/usr/bin/retroarch ${INSTALL}/usr/bin/retroarch32
    patchelf --set-interpreter /usr/lib32/ld-linux-armhf.so.3 ${INSTALL}/usr/bin/retroarch32
    cp -vP $PKG_BUILD/../../build.${DISTRO}-${DEVICE}.arm-${VERSION}/pcsx_rearmed-*/.install_pkg/usr/lib/libretro/pcsx_rearmed_libretro.so ${INSTALL}${INSTALLTO}
    chmod -f +x ${INSTALL}/usr/lib32/* || :
else
    cp pcsx_rearmed_libretro.so ${INSTALL}${INSTALLTO}
fi
}
