cmake_minimum_required(VERSION 3.10)
project(flutter_cv2_camera_plugin)

# Locate Flutter's generated include path for Linux desktop
set(FLUTTER_MANAGED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/flutter")
set(FLUTTER_INCLUDE_DIR "${FLUTTER_MANAGED_DIR}/ephemeral/include")

# Path to native C++ camera logic (relative to plugin dir)
add_subdirectory(../native_cv2 native_cv2_build)

# Define the plugin shared library
add_library(flutter_cv2_camera_plugin SHARED
  flutter_cv2_camera_plugin.cc
)

# Include Flutter headers + native OpenCV headers
target_include_directories(flutter_cv2_camera_plugin PUBLIC
  "${FLUTTER_INCLUDE_DIR}"
  ../native_cv2
)

# Link against native OpenCV camera lib
target_link_libraries(flutter_cv2_camera_plugin
  native_cv2
)

# Define Flutter plugin macro
target_compile_definitions(flutter_cv2_camera_plugin
  PRIVATE FLUTTER_PLUGIN_IMPL
)

# Copy libnative_cv2.so to the bundle output directory (Flutter runs from here)
add_custom_command(
  TARGET flutter_cv2_camera_plugin POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy_if_different
    $<TARGET_FILE:native_cv2>
    ${PROJECT_BINARY_DIR}/../bundle/libnative_cv2.so
)

add_custom_command(
  TARGET flutter_cv2_camera_plugin POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy_if_different
    $<TARGET_FILE:flutter_cv2_camera_plugin>
    ${PROJECT_BINARY_DIR}/../bundle/libflutter_cv2_camera_plugin.so
)
