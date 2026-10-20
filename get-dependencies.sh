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
	fluxbox \
	xterm \
	xdg-utils \
	ttf-dejavu \
	ttf-liberation

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano

echo "Building lumina..."
echo "---------------------------------------------------------------"
git clone https://github.com/lumina-desktop/lumina.git ./lumina
cd ./lumina
git checkout v1.6.2
git rev-parse --short HEAD > ~/version

# two upstream portability bugs, see README.md and lumina-portability.patch
patch -p1 < ../lumina-portability.patch

qmake-qt5 PREFIX=/usr src-qt5/src-qt5.pro
make -j"$(nproc)"
make install
