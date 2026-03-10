#!/bin/zsh
set -e
cd "$(dirname "$0")"

echo "Building NookClone..."
xcodebuild -project NookClone.xcodeproj \
  -scheme NookClone \
  -configuration Debug \
  SYMROOT="$(pwd)/build" \
  build 2>&1 | grep -E "error:|BUILD SUCCEEDED|BUILD FAILED"

echo "Signing..."
find build/Debug/NookClone.app -exec xattr -c {} \; 2>/dev/null
codesign --force --deep --sign - build/Debug/NookClone.app

echo "Launching..."
pkill -x NookClone 2>/dev/null; sleep 0.3
open build/Debug/NookClone.app
echo "Done."
