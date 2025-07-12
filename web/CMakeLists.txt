cmake_minimum_required(VERSION 3.28.3)
project(flutter_cv2_camera_web)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Include the native_cv2 directory
add_subdirectory(../native_cv2 native_cv2_build)

# Set Emscripten-specific flags
set(CMAKE_EXECUTABLE_SUFFIX ".js")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -s WASM=1 -s MODULARIZE=1 -s EXPORT_ES6=1")

# Create the WASM module
add_executable(flutter_cv2_camera_web
    ../native_cv2/wasm/cv2_camera_web.cpp
)

target_link_libraries(flutter_cv2_camera_web PRIVATE
    cv2_camera_web
)

# Set output name and properties
set_target_properties(flutter_cv2_camera_web PROPERTIES
    OUTPUT_NAME "flutter_cv2_camera"
    SUFFIX ".js"
)