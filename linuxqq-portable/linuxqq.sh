#!/bin/bash

# QQ has no known switch for hot updates. Discard them so the version stays the one pacman installed.
rm -rf ~/.config/QQ/versions

rm -rf ~/.config/QQ/crash_files/*
if [[ "${XDG_SESSION_TYPE}" = "wayland" ]]; then
	flag="--ozone-platform=wayland"
fi

/opt/QQ/qq --no-sandbox ${flag} --enable-features=VaapiVideoDecodeLinuxGL,VaapiVideoDecoder,TouchpadOverscrollHistoryNavigation,WebRTCPipeWireCapturer,WebRtcPipeWireCamera,AcceleratedVideoDecodeLinuxGL,VaapiOnNvidiaGPUs --wayland-text-input-version=3 --enable-wayland-ime --ignore-gpu-blocklist "$@"