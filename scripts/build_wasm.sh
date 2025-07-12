#!/bin/bash
set -eo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Paths
PROJECT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
BUILD_DIR="$PROJECT_DIR/build/wasm"
WEB_DIR="$PROJECT_DIR/web"
OPENCV_DIR="$WEB_DIR/opencv"

# Configuration
BUILD_TYPE="Release"
JOBS=$(nproc)

# Parse arguments
while getopts "dj:" opt; do
  case $opt in
    d) BUILD_TYPE="Debug" ;;
    j) JOBS="$OPTARG" ;;
    *) echo "Usage: $0 [-d] [-j jobs]" >&2
       exit 1 ;;
  esac
done

# Ensure Emscripten environment
source_emsdk() {
    if [ -f "$PROJECT_DIR/emsdk/emsdk_env.sh" ]; then
        source "$PROJECT_DIR/emsdk/emsdk_env.sh"
    else
        echo -e "${RED}❌ Emscripten not found. Please install it first.${NC}"
        exit 1
    fi
}

# Verify tools
verify_tools() {
    local missing=0
    for tool in emcmake emmake cmake; do
        if ! command -v $tool &> /dev/null; then
            echo -e "${RED}❌ $tool not found${NC}"
            missing=1
        fi
    done
    [ $missing -eq 0 ] || exit 1
}

# Setup OpenCV
setup_opencv() {
    mkdir -p "$OPENCV_DIR"
    
    if [ ! -f "$OPENCV_DIR/opencv.js" ] || [ ! -f "$OPENCV_DIR/opencv_js.wasm" ]; then
        echo -e "${YELLOW}⏳ Downloading OpenCV.js...${NC}"
        wget -O "$OPENCV_DIR/opencv.js" https://docs.opencv.org/4.5.5/opencv.js
        wget -O "$OPENCV_DIR/opencv_js.wasm" https://docs.opencv.org/4.5.5/opencv_js.wasm
    fi
}

# Build WASM
build_wasm() {
    mkdir -p "$BUILD_DIR"
    cd "$PROJECT_DIR"
    
    echo -e "${YELLOW}⚙️ Configuring build...${NC}"
    emcmake cmake -S native_cv2/wasm -B "$BUILD_DIR" \
        -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
        -DCMAKE_TOOLCHAIN_FILE="$EMSDK/upstream/emscripten/cmake/Modules/Platform/Emscripten.cmake"
    
    echo -e "${YELLOW}🔨 Building with $JOBS jobs...${NC}"
    emmake make -C "$BUILD_DIR" -j$JOBS
}

# Package output
package_output() {
    cp "$BUILD_DIR/flutter_cv2_camera.js" "$WEB_DIR/"
    cp "$BUILD_DIR/flutter_cv2_camera.wasm" "$WEB_DIR/"
    
    # Create minimal loader
    cat > "$WEB_DIR/cv2_camera_web_loader.js" <<EOL
const loadCV2Camera = async () => {
  if (!window.cv2CameraLoaded) {
    await new Promise((resolve) => {
      const script = document.createElement('script');
      script.src = 'flutter_cv2_camera.js';
      script.onload = resolve;
      document.body.appendChild(script);
    });
    window.cv2CameraLoaded = true;
  }
  return window.Module;
};

export default loadCV2Camera;
EOL
}

# Main execution
main() {
    echo -e "${GREEN}🚀 Starting WASM build...${NC}"
    
    source_emsdk
    verify_tools
    setup_opencv
    build_wasm
    package_output
    
    echo -e "${GREEN}🎉 Build successful!${NC}"
    echo -e "Output files:"
    echo -e "  - ${WEB_DIR}/flutter_cv2_camera.js"
    echo -e "  - ${WEB_DIR}/flutter_cv2_camera.wasm"
    echo -e "  - ${WEB_DIR}/cv2_camera_web_loader.js"
}

main