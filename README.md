# AUR-packages

A personal pacman repository built from the PKGBUILDs in this tree. Packages listed in `aur-packages.txt` are also published to the AUR under [RiverOnVenus](https://aur.archlinux.org/account/RiverOnvenus).

## What gets published

A directory listed in `aur-packages.txt` is pushed to the AUR. Everything else is still built and published to the personal repository. These directories are local rebuilds and forks of packages maintained elsewhere, kept here so updates follow this repository's review and build instead of being applied by an AUR helper.

Every push to `master` builds the package directories changed since the last fully successful push, then:

- adds the built packages to the repository database and publishes them to the `zhui-arch` release
- pushes the packages listed in `aur-packages.txt` to the AUR from a separate job, with `.SRCINFO` generated from the committed `PKGBUILD`

A VCS package rebuilt only because upstream has new commits gets a fresh build in `zhui-arch` but nothing new on the AUR. Packages that were not rebuilt keep their entries, and a failed build is retried on the next push. To rebuild a specific package, run the workflow manually with the `packages` input, or leave it empty to rebuild everything. Deleting a package directory removes it from the repository on the next push.

## Personal repository

Add this to `/etc/pacman.conf`:

```ini
[zhui-arch]
SigLevel = Optional TrustAll
Server = https://github.com/RiverOnVenus/AUR-packages/releases/download/zhui-arch
```

Then `pacman -Sy` and install by name. The database is updated after every `master` push, so new versions show up once the workflow finishes.

Packages installed from this repository are resolved against a sync database, so `paru` and `yay` no longer treat them as foreign and AUR updates stop replacing them.

## Credits

The build and release workflow started from [ouuan/AUR-template](https://github.com/ouuan/AUR-template) and has since been rewritten. Local rebuilds and forks of packages maintained on the AUR or in [Kraftland/portable-arch](https://github.com/Kraftland/portable-arch) keep the original `# Maintainer:` line and add a `# Contributor:` line. Each `PKGBUILD` names its upstream packagers.
