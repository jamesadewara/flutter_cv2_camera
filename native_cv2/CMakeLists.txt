cmake_minimum_required(VERSION 3.28.3)
project(native_cv2)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 1. Find OpenCV
find_package(OpenCV REQUIRED)

set(CMAKE_INCLUDE_CURRENT_DIR ON) 
set(CMAKE_CXX_VISIBILITY_PRESET default)
set(CMAKE_VISIBILITY_INLINES_HIDDEN OFF)

# 2. Create STATIC library
add_library(native_cv2 STATIC 
    cv2_camera.cpp
    cv2_camera.hpp
)

set_target_properties(native_cv2 PROPERTIES
    CXX_VISIBILITY_PRESET default
    VISIBILITY_INLINES_HIDDEN OFF
    POSITION_INDEPENDENT_CODE ON
)

target_compile_options(native_cv2 PRIVATE
    -fvisibility=default
)

# 3. Include directories
target_include_directories(native_cv2 PUBLIC
    ${OpenCV_INCLUDE_DIRS}
    ${CMAKE_CURRENT_SOURCE_DIR}
)

# 4. Optional test executable
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/test.cpp")
    add_executable(test_cv2 test.cpp)
    target_link_libraries(test_cv2 PRIVATE
        native_cv2
        ${OpenCV_LIBS}
    )
endif()