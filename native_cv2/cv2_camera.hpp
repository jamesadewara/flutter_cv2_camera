#ifndef CV2_CAMERA_HPP
#define CV2_CAMERA_HPP

#include <cstdint>  

#ifdef __cplusplus
extern "C" {
#endif

void start_camera();
void stop_camera();
uint8_t* get_frame(int* length); 
void free_frame(uint8_t* buffer);
void flipcode_camera(int flipCode);
void set_resolution(int width, int height);
void switch_camera(int cameraIndex);

#ifdef __cplusplus
}
#endif

#endif