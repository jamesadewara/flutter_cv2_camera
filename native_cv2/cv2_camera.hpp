#pragma once
#include <cstdint>

extern "C" {
    void start_camera();
    void stop_camera();
    uint8_t* get_frame(int* length); // returns image bytes, updates length
    void free_frame(uint8_t* buffer);
    void flipcode_camera(int flipCode); 
}
