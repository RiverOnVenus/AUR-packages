#!/bin/bash
set -e

_APPDIR="/usr/lib/@appname@"
_RUNNAME="${_APPDIR}/@runname@"

export ELECTRON_IS_DEV=0
export ELECTRON_FORCE_IS_PACKAGED=true
export ELECTRON_DISABLE_SECURITY_WARNINGS=true
export NODE_ENV=production

# Extend lib path for bundled native modules
export LD_LIBRARY_PATH="${_APPDIR}:${LD_LIBRARY_PATH}"

# Default to X11 for drag-and-drop and mouse tracking (user can override with --ozone-platform=wayland)
exec electron@electronversion@ "${_RUNNAME}" --ozone-platform=x11 "$@"
