#!/bin/bash
set -eo pipefail

PROJECT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
WEB_DIR="$PROJECT_DIR/web"
OPENCV_DIR="$WEB_DIR/opencv"

echo "🔧 Setting up OpenCV for WebAssembly..."

# Create directory structure
mkdir -p "$OPENCV_DIR"

# Download official OpenCV.js build
OPENCV_VERSION="4.5.5"
BASE_URL="https://docs.opencv.org/$OPENCV_VERSION"

echo "⬇️ Downloading OpenCV.js v$OPENCV_VERSION..."
wget -q --tries=3 --timeout=20 -O "$OPENCV_DIR/opencv.js" "$BASE_URL/opencv.js"
wget -q --tries=3 --timeout=20 -O "$OPENCV_DIR/opencv_js.wasm" "$BASE_URL/opencv_js.wasm"

echo "✅ OpenCV.js setup complete!"