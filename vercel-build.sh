#!/bin/bash
set -e

echo "=== ColorSight Vercel Build Pipeline ==="

# Clone Flutter SDK if not cached
if [ ! -d "flutter" ]; then
  echo "Cloning Flutter SDK (stable branch, depth 1)..."
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable flutter
else
  echo "Flutter directory found in cache."
fi

# Add Flutter to PATH
export PATH="$PATH:$(pwd)/flutter/bin"

# Disable analytics and prepare web
flutter config --no-analytics
flutter doctor -v

# Fetch project dependencies
flutter pub get

# Compile production web release
echo "Compiling Flutter Web (CanvasKit)..."
flutter build web --release

echo "=== Build Complete: Output in build/web ==="
