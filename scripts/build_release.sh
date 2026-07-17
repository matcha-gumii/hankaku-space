#!/bin/zsh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DERIVED_DATA="$ROOT/build/DerivedData"

xcodebuild \
  -project "$ROOT/HankakuSpace.xcodeproj" \
  -scheme HankakuSpace \
  -configuration Release \
  -destination "platform=macOS,arch=arm64" \
  -derivedDataPath "$DERIVED_DATA" \
  CODE_SIGNING_ALLOWED=NO \
  clean build

APP="$DERIVED_DATA/Build/Products/Release/HankakuSpace.app"
test -d "$APP"
xattr -cr "$APP"
codesign --force --deep --sign - "$APP"
codesign --verify --deep --strict "$APP"

echo "$APP"
