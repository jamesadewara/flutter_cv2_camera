#include "cv2_camera.hpp"
#include <opencv2/opencv.hpp>
#include <thread>
#include <mutex>

static cv::VideoCapture cap;
static cv::Mat currentFrame;
static std::mutex frameMutex;
static bool running = false;
static int globalFlipCode = -2;  // -2 means no flipping

extern "C" void start_camera() {
    if (running) return;
    cap.open(0); // Default camera
    running = true;
    std::thread([=]() {
        while (running) {
            cv::Mat frame;
            cap >> frame;
            if (!frame.empty()) {
                if (globalFlipCode != -2) {
                    cv::flip(frame, frame, globalFlipCode);
                }
                std::lock_guard<std::mutex> lock(frameMutex);
                frame.copyTo(currentFrame);
            }
        }
    }).detach();
}

extern "C" void stop_camera() {
    running = false;
    cap.release();
}

extern "C" uint8_t* get_frame(int* length) {
    std::lock_guard<std::mutex> lock(frameMutex);
    if (currentFrame.empty()) {
        *length = 0;
        return nullptr;
    }
    std::vector<uchar> buf;
    cv::imencode(".jpg", currentFrame, buf);
    *length = buf.size();
    uint8_t* result = new uint8_t[*length];
    std::copy(buf.begin(), buf.end(), result);
    return result;
}

extern "C" void free_frame(uint8_t* buffer) {
    delete[] buffer;
}

extern "C" void flipcode_camera(int flipCode) {
    // -1: flip both axes, 0: vertical, 1: horizontal
    if (flipCode == -1 || flipCode == 0 || flipCode == 1 || flipCode == -2) {
        globalFlipCode = flipCode;
    }
}
