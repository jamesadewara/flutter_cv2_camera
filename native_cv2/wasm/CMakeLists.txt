cmake_minimum_required(VERSION 3.15)
project(flutter_cv2_camera_web)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Emscripten settings
set(CMAKE_EXECUTABLE_SUFFIX ".js")

# Compiler flags
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} \
    -s WASM=1 \
    -s ALLOW_MEMORY_GROWTH=1 \
    -s MODULARIZE=1 \
    -s EXPORT_ES6=1 \
    -s USE_PTHREADS=0 \
    -s DISABLE_EXCEPTION_CATCHING=0")

# Linker flags
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} \
    -s EXPORTED_FUNCTIONS='[\"_onOpenCVReady\",\"_onCameraStarted\",\"_onCameraError\"]' \
    -s EXPORTED_RUNTIME_METHODS='[\"ccall\",\"cwrap\",\"UTF8ToString\"]' \
    -s BINDING=1")

# Source files
add_executable(flutter_cv2_camera
    cv2_camera_web.cpp
)

set_target_properties(flutter_cv2_camera PROPERTIES
    OUTPUT_NAME "flutter_cv2_camera"
    SUFFIX ".js"
)