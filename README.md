# AUR-packages

AUR packages maintained by [RiverOnVenus](https://aur.archlinux.org/account/RiverOnvenus), built into a personal pacman repository alongside the AUR publication.

## Template

This repository is based on [ouuan/AUR-template](https://github.com/ouuan/AUR-template).

## What gets published

`aur-packages.txt` lists the packages that are pushed to the AUR. A directory that is not listed there is still built and published to the personal repository, but is never uploaded to the AUR.

Every push builds all package directories and generates `.SRCINFO`, then:

- pushes the packages listed in `aur-packages.txt` to the AUR
- publishes every built package, plus the repository database, to the `zhui-arch` release

A package that fails to build blocks the whole run, including the repository update.

## Personal repository

Add this to `/etc/pacman.conf`:

```ini
[zhui-arch]
SigLevel = Optional TrustAll
Server = https://github.com/RiverOnVenus/AUR-packages/releases/download/zhui-arch
```

Then `pacman -Sy` and install by name. The database is rebuilt on every push, so new versions show up after the workflow finishes.

Packages installed from this repository are resolved against a sync database, which means they are no longer treated as foreign by `paru` and `yay`. AUR updates stop replacing them.
