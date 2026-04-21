#!/bin/bash
set -e

echo "==> Installing Flutter 3.41.7 (stable)..."
curl -s https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.41.7-stable.tar.xz \
  -o flutter.tar.xz
tar xf flutter.tar.xz
export PATH="$PATH:$(pwd)/flutter/bin"

echo "==> Configuring Flutter..."
flutter config --enable-web --no-analytics

echo "==> Getting dependencies..."
flutter pub get

echo "==> Building Flutter web (release)..."
flutter build web --release

echo "==> Build complete! Output in build/web"
