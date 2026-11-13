#!/bin/sh
# The installed tree is root-owned, so the in-app updater can only fail.
# Updates come from pacman.
export VOICESTUDIO_DISABLE_UPDATER=1
exec /opt/VoiceStudio/voicestudio "$@"
