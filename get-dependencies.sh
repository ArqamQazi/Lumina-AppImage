#!/bin/sh

set -eu

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
	base-devel \
	git \
	patchelf \
	qt5-base \
	qt5-declarative \
	qt5-imageformats \
	qt5-multimedia \
	qt5-svg \
	qt5-tools \
	qt5-translations \
	qt5-x11extras \
	libxdamage \
	libxcursor \
	libx11 \
	libxcb \
	xcb-util \
	xcb-util-image \
	xcb-util-keysyms \
	xcb-util-renderutil \
	xcb-util-wm \
	fluxbox \
	xterm \
	xdg-utils \
	xdg-user-dirs \
	ttf-dejavu \
	ttf-liberation

echo "Building lumina..."
echo "---------------------------------------------------------------"
rm -rf ./lumina
git clone https://github.com/lumina-desktop/lumina.git ./lumina
cd ./lumina
git checkout v1.6.2
git rev-parse --short HEAD > ~/version

# two upstream portability bugs, see README.md and lumina-portability.patch
patch -p1 < ../lumina-portability.patch

qmake-qt5 PREFIX=/usr src-qt5/src-qt5.pro
make -j"$(nproc)"
make install
cd ..

test -x /usr/bin/start-lumina-desktop
test -x /usr/bin/lumina-desktop

# after pacman and after the build, so a debloated mesa can never
# interfere with the Qt5 toolchain that just compiled Lumina
echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-mesa --prefer-nano icu-mini
