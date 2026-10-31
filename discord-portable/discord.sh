#!/usr/bin/bash
if [ -f /usr/share/discord-bwrap/settings.json ]; then
	install -vDm644 /usr/share/discord-bwrap/settings.json "$HOME/.config/discord/settings.json"
fi
/opt/discord/Discord --ozone-platform-hint=auto --enable-features=AcceleratedVideoEncoder,AcceleratedVideoDecoder,AcceleratedVideoDecodeLinuxGL,VaapiIgnoreDriverChecks  --wayland-text-input-version=3 --enable-wayland-ime --no-sandbox "$@"
