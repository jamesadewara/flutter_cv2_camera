#include "cv2_camera.hpp"
#include <opencv2/opencv.hpp>
#include <thread>
#include <mutex>
#include <cstdint>

static cv::VideoCapture cap;
static cv::Mat currentFrame;
static std::mutex frameMutex;
static bool running = false;
static int globalFlipCode = -2;  // -2 means no flipping
static int cameraIndex = 0;
static int resolutionWidth = 640;
static int resolutionHeight = 480;

void captureLoop() {
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
}

extern "C" void start_camera() {
    if (running) return;
    cap.open(cameraIndex);
    cap.set(cv::CAP_PROP_FRAME_WIDTH, resolutionWidth);
    cap.set(cv::CAP_PROP_FRAME_HEIGHT, resolutionHeight);

    if (!cap.isOpened()) return;
    running = true;
    std::thread(captureLoop).detach();
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
    if (flipCode == -1 || flipCode == 0 || flipCode == 1 || flipCode == -2) {
        globalFlipCode = flipCode;
    }
}

extern "C" void set_resolution(int width, int height) {
    resolutionWidth = width;
    resolutionHeight = height;
    if (cap.isOpened()) {
        cap.set(cv::CAP_PROP_FRAME_WIDTH, resolutionWidth);
        cap.set(cv::CAP_PROP_FRAME_HEIGHT, resolutionHeight);
    }
}

extern "C" void switch_camera(int index) {
    if (index == cameraIndex) return;
    stop_camera();
    cameraIndex = index;
    start_camera();
}
