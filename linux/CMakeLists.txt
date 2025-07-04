cmake_minimum_required(VERSION 3.28.3)
project(flutter_cv2_camera_plugin)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 1. Basic setup
include_directories(
    "${CMAKE_CURRENT_SOURCE_DIR}/../native_cv2"
    "${CMAKE_CURRENT_SOURCE_DIR}/flutter/ephemeral/include"
)

set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

# 2. Build native_cv2 as STATIC library
add_subdirectory(../native_cv2 native_cv2_build)

# 3. Build FFI library
add_library(flutter_cv2_camera_plugin SHARED
    flutter_cv2_camera_plugin.cc
)

target_include_directories(flutter_cv2_camera_plugin PRIVATE
    "${CMAKE_CURRENT_SOURCE_DIR}/../native_cv2"
)

# 4. Find and link dependencies
find_package(Threads REQUIRED)
find_package(OpenCV REQUIRED)

target_link_libraries(flutter_cv2_camera_plugin PRIVATE
    native_cv2
    ${OpenCV_LIBS}
    Threads::Threads
)

# 5. Install the main plugin library
install(TARGETS flutter_cv2_camera_plugin
    LIBRARY DESTINATION "${CMAKE_BINARY_DIR}/bundle/lib"
    RUNTIME DESTINATION "${CMAKE_BINARY_DIR}/bundle/bin"
    ARCHIVE DESTINATION "${CMAKE_BINARY_DIR}/bundle/lib"
)