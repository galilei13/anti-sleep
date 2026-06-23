#!/usr/bin/env bash
#
# make_dmg.sh — bundle a compiled .app into a distributable .dmg
#
# Usage: ./scripts/make_dmg.sh <path/to/App.app> <path/to/output.dmg> [VolumeName]
#
# Produces a compressed (UDZO) disk image containing the app plus a symlink
# to /Applications so users can drag-to-install. Uses only system tools
# (hdiutil), so no extra dependencies are required.

set -euo pipefail

APP_PATH="${1:?Usage: make_dmg.sh <App.app> <output.dmg> [VolumeName]}"
DMG_PATH="${2:?Usage: make_dmg.sh <App.app> <output.dmg> [VolumeName]}"
VOL_NAME="${3:-AntiSleep}"

if [[ ! -d "$APP_PATH" ]]; then
  echo "error: app bundle not found at '$APP_PATH'" >&2
  exit 1
fi

STAGING="$(mktemp -d)"
trap 'rm -rf "$STAGING"' EXIT

echo "==> Staging contents"
cp -R "$APP_PATH" "$STAGING/"
ln -s /Applications "$STAGING/Applications"

mkdir -p "$(dirname "$DMG_PATH")"
rm -f "$DMG_PATH"

echo "==> Creating compressed disk image: $DMG_PATH"
hdiutil create \
  -volname "$VOL_NAME" \
  -srcfolder "$STAGING" \
  -ov \
  -format UDZO \
  "$DMG_PATH"

echo "==> Done: $DMG_PATH"
