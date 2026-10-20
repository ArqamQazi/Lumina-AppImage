#!/bin/sh

set -eu

ARCH=$(uname -m)
export ARCH
export OUTPATH=./dist
export OUTNAME=Lumina-"$ARCH".AppImage
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export DEPLOY_LOCALE=1
export DEPLOY_OPENGL=1
export ANYLINUX_LIB=1
export MAIN_BIN=start-lumina-desktop

SHARUN="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/quick-sharun.sh"

./get-dependencies.sh

wget "$SHARUN" -O ./quick-sharun
chmod +x ./quick-sharun

# start-lumina-desktop is the session launcher, it starts lumina-desktop
# and the window manager itself, so every helper has to be bundled by name
export PATH=$PWD:$PATH

./quick-sharun \
	/usr/bin/start-lumina-desktop \
	/usr/bin/lumina-* \
	/usr/bin/fluxbox \
	/usr/bin/xterm \
	/usr/bin/xdg-open \
	/usr/bin/xdg-user-dirs-update

./quick-sharun --make-appimage
