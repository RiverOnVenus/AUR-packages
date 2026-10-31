# AUR-packages

A personal pacman repository built from the PKGBUILDs in this repository. Packages listed in `aur-packages.txt` are also published to the AUR, where [RiverOnVenus](https://aur.archlinux.org/account/RiverOnvenus) maintains them. Not every directory here belongs to a package maintained on the AUR by the same person.

## Template

This repository is based on [ouuan/AUR-template](https://github.com/ouuan/AUR-template).

## What gets published

`aur-packages.txt` lists the packages that are pushed to the AUR. A directory that is not listed there is still built and published to the personal repository, but is never uploaded to the AUR. These are local rebuilds or forks of packages maintained elsewhere, on the AUR or in [Kraftland/portable-arch](https://github.com/Kraftland/portable-arch), and their `PKGBUILD` keeps the original maintainer line and adds a `# Contributor:` line. Keeping them here means updates follow this repository's review and build instead of being applied by an AUR helper.

Every push builds the package directories it touches and generates `.SRCINFO`, then:

- pushes the packages listed in `aur-packages.txt` to the AUR
- adds the built packages to the repository database and publishes them to the `zhui-arch` release

Packages that were not rebuilt keep their entries, so one failing build no longer takes the whole repository down with it. To rebuild a specific package, run the workflow manually with the `packages` input; leave it empty to rebuild everything. Deleting a package directory removes it from the repository on the next push.

## Personal repository

Add this to `/etc/pacman.conf`:

```ini
[zhui-arch]
SigLevel = Optional TrustAll
Server = https://github.com/RiverOnVenus/AUR-packages/releases/download/zhui-arch
```

Then `pacman -Sy` and install by name. The database is updated on every push, so new versions show up after the workflow finishes.

Packages installed from this repository are resolved against a sync database, which means they are no longer treated as foreign by `paru` and `yay`. AUR updates stop replacing them.
