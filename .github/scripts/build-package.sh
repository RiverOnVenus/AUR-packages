#!/bin/bash
# Builds one package directory inside a fresh archlinux:base-devel container.
#
# Usage: build-package.sh <package-dir> <output-dir>
#
# Sets up the container as root, then runs makepkg and paru as a separate
# user because they refuse to run as root. That user has passwordless sudo,
# so the container itself is the isolation boundary. Debug packages are turned
# off. Every package the build produces is copied to <output-dir>, except a
# debug package that a PKGBUILD turns back on.
set -euo pipefail

src=$1
out=$2

warn() {
  local text="$1"
  [ -n "$text" ] || return 0
  text="${text//'%'/'%25'}"
  text="${text//$'\n'/'%0A'}"
  text="${text//$'\r'/'%0D'}"
  echo "::warning::$text"
}

echo "::group::Configure pacman"
# pacman's built-in downloader aborts after 10s below 1 B/s and never retries,
# so one stalled GitHub release download fails the whole build. curl retries
# the transfer and keeps the same low-speed cutoff.
sed -i '\|^\[options\]|a XferCommand = /usr/bin/curl -L -f -o %o %u --retry 5 --retry-delay 3 --speed-limit 1 --speed-time 10' /etc/pacman.conf

# Dependencies resolve from the official repositories first, then from this
# repository's own release, so a package depending on another one here gets
# the reviewed build instead of the AUR version. Only what neither provides
# falls through to the AUR.
cat >> /etc/pacman.conf <<'EOF'

[multilib]
Include = /etc/pacman.d/mirrorlist
EOF

# A missing release is skipped so the repository can be rebuilt from scratch.
# Any other failure stops the build, so a dependency never falls through to
# the AUR just because the release was briefly unreachable.
repo_url=https://github.com/RiverOnVenus/AUR-packages/releases/download/zhui-arch
code=$(curl -sSLo /dev/null -w '%{http_code}' --retry 3 --retry-delay 5 \
  "$repo_url/zhui-arch.db" || true)
case "$code" in
  200)
    printf '\n[zhui-arch]\nSigLevel = Optional TrustAll\nServer = %s\n' "$repo_url" >> /etc/pacman.conf
    ;;
  404)
    warn "zhui-arch database not found, building without it"
    ;;
  *)
    echo "::error::could not reach the zhui-arch database (HTTP ${code:-none})"
    exit 1
    ;;
esac

# archlinuxcn is enabled only long enough to install paru, so no other
# dependency can come from it.
cat >> /etc/pacman.conf <<'EOF'

[archlinuxcn]
Server = https://repo.archlinuxcn.org/$arch
EOF
pacman-key --init
pacman -Syu --noconfirm
pacman -S --noconfirm archlinuxcn-keyring
pacman -S --noconfirm paru
pacman -Rns --noconfirm archlinuxcn-keyring
sed -i '/^\[archlinuxcn\]$/,$d' /etc/pacman.conf
pacman -Syy

# The repository publishes no debug packages, so none is built, for AUR
# dependencies either. The last OPTIONS entry wins, and a PKGBUILD's own
# options still override it.
echo "OPTIONS+=('!debug')" > /etc/makepkg.conf.d/no-debug.conf
echo "::endgroup::"

echo "::group::Prepare build user"
useradd -m builder
echo 'builder ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/builder
chmod 0440 /etc/sudoers.d/builder
work=/home/builder/pkg
cp -r "$src" "$work"
chown -R builder:builder "$work"
echo "::endgroup::"

as_builder() {
  # runuser keeps MAKEFLAGS and PACKAGER from the container environment.
  (cd "$work" && runuser -u builder -- "$@")
}

echo "::group::Install dependencies"
as_builder makepkg --printsrcinfo > /tmp/srcinfo
pkgbase=$(sed -nE 's/^pkgbase = //p' /tmp/srcinfo)
# Reading .SRCINFO also covers architecture-specific arrays such as
# depends_x86_64, which sourcing the PKGBUILD would miss.
mapfile -t deps < <(sed -nE 's/^\t(depends|makedepends|checkdepends)(_x86_64)? = //p' /tmp/srcinfo | sort -u)
if [ ${#deps[@]} -gt 0 ]; then
  as_builder paru -S --noconfirm --needed --asdeps --skipreview --nocheck --removemake "${deps[@]}"
fi
pacman -Rns --noconfirm paru
echo "::endgroup::"

echo "::group::Make package"
as_builder makepkg --noconfirm --syncdeps 2>&1 | tee /tmp/build.log
warn "$(grep 'WARNING' /tmp/build.log || true)"
echo "::endgroup::"

echo "::group::Collect packages"
# makepkg has written the pkgver() result back into the PKGBUILD by now, so
# the list names the files that were actually built.
# When a PKGBUILD turns debug back on, the list also names the debug package,
# whether or not one was built.
mapfile -t files < <(as_builder makepkg --packagelist)
for f in "${files[@]}"; do
  name=$(basename "$f")
  [ "${name%-*-*-*}" = "$pkgbase-debug" ] && continue
  pacman -Qip "$f"
  pacman -Qlp "$f"
  cp "$f" "$out/"
done
echo "::endgroup::"

echo "::group::Run namcap"
pacman -S --noconfirm --needed namcap
warn "$(as_builder namcap PKGBUILD || true)"
for f in "$out"/*; do
  warn "$(namcap "$f" || true)"
done
echo "::endgroup::"
