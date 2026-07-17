#!/bin/zsh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="$ROOT/build/DerivedData/Build/Products/Release/HankakuSpace.app"
STAGING="$(mktemp -d /tmp/HankakuSpace-dmg.XXXXXX)"
OUTPUT="$ROOT/dist/HankakuSpace.dmg"
trap 'rm -rf "$STAGING"' EXIT

"$ROOT/scripts/build_release.sh"

mkdir -p "$ROOT/dist"
ditto --noextattr "$APP" "$STAGING/HankakuSpace.app"
xattr -cr "$STAGING/HankakuSpace.app"
codesign --force --deep --sign - "$STAGING/HankakuSpace.app"
codesign --verify --deep --strict "$STAGING/HankakuSpace.app"
ln -s /Applications "$STAGING/Applications"
rm -f "$OUTPUT"

hdiutil create \
  -volname "Hankaku Space" \
  -srcfolder "$STAGING" \
  -ov \
  -format UDZO \
  "$OUTPUT"

hdiutil verify "$OUTPUT"
echo "$OUTPUT"
