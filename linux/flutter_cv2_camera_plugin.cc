#include "../native_cv2/cv2_camera.hpp"
#include <cstring>

extern "C" {
    void StartCamera() { start_camera(); }
    void StopCamera() { stop_camera(); }
    uint8_t* GetFrame(int* length) { return get_frame(length); }
    void FreeFrame(uint8_t* buffer) { free_frame(buffer); }
    void FlipcodeCamera(int flipCode) { flipcode_camera(flipCode); }
}