cmake_minimum_required(VERSION 3.10)
project(native_cv2)

find_package(PkgConfig REQUIRED)
pkg_check_modules(OPENCV REQUIRED opencv4)

include_directories(${OPENCV_INCLUDE_DIRS})
link_directories(${OPENCV_LIBRARY_DIRS})
add_definitions(${OPENCV_CFLAGS_OTHER})

# Shared library
add_library(native_cv2 SHARED cv2_camera.cpp)
target_link_libraries(native_cv2 ${OPENCV_LIBRARIES})

# Test executable
add_executable(test_cv2 test.cpp cv2_camera.cpp)
target_link_libraries(test_cv2 ${OPENCV_LIBRARIES})

# Make sure the .so is named properly
set_target_properties(native_cv2 PROPERTIES OUTPUT_NAME "native_cv2")