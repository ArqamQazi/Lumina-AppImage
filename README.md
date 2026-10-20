# Lumina Desktop AppImage

An [Anylinux AppImage](https://github.com/pkgforge-dev/Anylinux-AppImages) of the
[Lumina Desktop Environment](https://github.com/lumina-desktop/lumina), built with
[quick-sharun](https://github.com/pkgforge-dev/Anylinux-AppImages/blob/main/useful-tools/quick-sharun.sh).

Lumina is a plugin based, Qt5-only desktop: a panel, a desktop, a start menu and
a set of small utilities. It is unmaintained upstream (last release 1.6.2, from
2021) and is not packaged in the Arch repositories, so an AppImage is the only
way to run it on a current distribution without building it yourself.

It bundles everything it needs, including Qt5, fluxbox (its default window
manager), xterm and Mesa, so it does not depend on the host userland.

## Status

**Work in progress.** Please read this before trying it.

Verified in a build sandbox:

- Lumina 1.6.2 builds from source against Qt 5.15 and installs to `/usr`.
- The desktop renders and stays up when its data directory is found:
  `start-lumina-desktop` starts fluxbox and `lumina-desktop`, the panel, the
  start menu, the clock and the wallpaper all appear.
- The two patches below are both needed for that, and both are applied at build
  time (see `lumina-portability.patch`).
- The AppImage builds with quick-sharun, bundles the Qt5 xcb platform plugin and
  its `libQt5XcbQpa` dependency, and `libmd4c`, which a naive `ldd` pass misses.

**Not yet verified:** launching the session from inside the finished AppImage in
this sandbox. The extracted AppDir runs the whole session, but when
`start-lumina-desktop` is run as the AppImage's entry point the spawned
`lumina-desktop` exits with code 255 and writes nothing to its log. That is the
one remaining problem and it is described at the bottom of this file.

## Patches

`lumina-portability.patch` contains two changes, both upstream bugs that only
show up outside the author's environment:

1. **DPMS is optional.** `LXCB::enableDPMS()` and `disableDPMS()` send
   `xcb_dpms_enable()` unconditionally. A server without the DPMS extension
   answers with a BadRequest, and xcb tears the connection down, so the session
   dies right after the wallpaper is painted with
   `The X11 connection broke (error 2). Did the X11 server die?`. This affects
   Xvfb, Xorg's dummy driver and various nested/VNC servers. The patch queries
   the extension once and skips the requests when it is missing;
   `XSetScreenSaver()` remains as the pre-DPMS fallback.
2. **The data directory is relocatable.** `LOS::LuminaShare()` returns a compile
   time path (`/usr/share/lumina-desktop/`), so an AppImage cannot find its own
   data. The patch honours `LUMINA_SHARE_DIR` when it is set, which
   `AppDir/bin/lumina-share-dir.hook` points at the AppDir.

Both are worth sending upstream even though the project is dormant.

## Building

Deploying on any system other than Arch Linux is a very bad idea. Lumina must be
installed to `/usr` before it is deployed, which is what `get-dependencies.sh`
does.

```sh
./get-dependencies.sh
./make-appimage.sh
```

The result is `dist/Lumina-x86_64.AppImage`.

## Running

Start it from your session manager, or directly:

```sh
./Lumina-x86_64.AppImage
```

If `DISPLAY` is unset, `start-lumina-desktop` calls `xinit` to bring up its own
X server. That is Lumina's own behaviour, not something the AppImage adds.

## Known issue

The session launcher spawns the desktop binary through `QProcess`. Inside the
AppImage that spawn fails and the child exits 255 without writing to
`$XDG_CONFIG_HOME/lumina-desktop/logs/runtime_<display>.log`. The same binary
started by hand from the extracted AppDir runs the full session, so the bundle
itself is complete; what is left is the nested spawn.

Ideas that were checked and ruled out: a missing `libQt5XcbQpa.so.5` (now
bundled), the Qt xcb plugin (loads), a missing `/usr/share/lumina-desktop`
(the hook fixes it), a missing `/etc/machine-id` (bundling `dbus-launch` makes
it worse, because `dbus-launch` needs a passwd entry the sandbox lacks), and
`ldd` failing to report Qt plugin dependencies (worked around while building).

## Credits

- Lumina Desktop Environment, 3-clause BSD, by Ken Moore and contributors.
- [quick-sharun](https://github.com/pkgforge-dev/Anylinux-AppImages) and
  [sharun](https://github.com/VHSgunzo/sharun), from pkgforge-dev and VHSgunzo.
