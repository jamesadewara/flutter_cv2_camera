#include "cv2_camera.hpp"
#include <opencv2/opencv.hpp>
#include <iostream>
#include <thread>
#include <chrono>
#include <filesystem>
#include <vector>
#include <string>
#include <termios.h>
#include <unistd.h>

namespace fs = std::filesystem;

static int cameraIndex = 0;
static int width = 640;
static int height = 480;

// Utility to get char without waiting for enter
char getch() {
    struct termios oldt{}, newt{};
    char ch;
    tcgetattr(STDIN_FILENO, &oldt);
    newt = oldt;
    newt.c_lflag &= ~(ICANON);  // disable buffered I/O
    tcsetattr(STDIN_FILENO, TCSANOW, &newt);
    ch = getchar();
    tcsetattr(STDIN_FILENO, TCSANOW, &oldt);
    return ch;
}

void list_available_cameras(int max_test = 5) {
    std::cout << "Available cameras:\n";
    for (int i = 0; i < max_test; ++i) {
        cv::VideoCapture testCap(i);
        if (testCap.isOpened()) {
            std::cout << "  - Index " << i << "\n";
            testCap.release();
        }
    }
}

int main() {
    start_camera();
    set_resolution(width, height);
    switch_camera(cameraIndex);

    std::cout << "Camera started on index " << cameraIndex << ".\n";
    std::cout << "Keys:\n"
              << "  's' → Save frame\n"
              << "  'f' → Flip\n"
              << "  '0-9' → Switch camera\n"
              << "  Shift + Enter → Set width\n"
              << "  Ctrl + Enter  → Set height\n"
              << "  'q' → Quit\n";

    fs::create_directories("pics");
    cv::Mat img;
    int frameCount = 0;
    int flipCode = -2;
    flipcode_camera(flipCode);

    bool settingWidth = false;
    bool settingHeight = false;
    std::string inputBuffer;

    while (true) {
        int len = 0;
        uint8_t* buffer = get_frame(&len);

        if (len > 0 && buffer != nullptr) {
            std::vector<uchar> imgData(buffer, buffer + len);
            img = cv::imdecode(imgData, cv::IMREAD_COLOR);
            free_frame(buffer);

            if (!img.empty()) {
                cv::imshow("Live Camera", img);
            } else {
                std::cerr << "Frame decode failed.\n";
            }
        }

        char key = (char)cv::waitKey(30);

        if (key >= '0' && key <= '9') {
            int newIndex = key - '0';
            stop_camera();
            switch_camera(newIndex);
            start_camera();
            std::cout << "Switched to camera index: " << newIndex << "\n";

            int lenCheck = 0;
            uint8_t* testBuf = get_frame(&lenCheck);
            if (lenCheck == 0 || testBuf == nullptr) {
                std::cerr << "❌ Camera " << newIndex << " not available.\n";
                list_available_cameras();
                switch_camera(cameraIndex);  // revert
                start_camera();
            } else {
                free_frame(testBuf);
                cameraIndex = newIndex;
            }
        } else if (key == 's') {
            std::string filename = "pics/frame_" + std::to_string(frameCount++) + ".jpg";
            if (!img.empty()) {
                cv::imwrite(filename, img);
                std::cout << "📸 Saved: " << filename << "\n";
            }
        } else if (key == 'f') {
            flipCode = (flipCode == -2) ? 0 : (flipCode == 0) ? 1 : (flipCode == 1) ? -1 : -2;
            flipcode_camera(flipCode);
            std::cout << "🔄 FlipCode changed to: " << flipCode << "\n";
        } else if (key == 81) {  // Shift key + Enter simulation
            std::cout << "Enter new width: ";
            std::cin >> width;
            set_resolution(width, height);
            std::cout << "✅ Width set to " << width << "\n";
        } else if (key == 83) {  // Ctrl key + Enter simulation
            std::cout << "Enter new height: ";
            std::cin >> height;
            set_resolution(width, height);
            std::cout << "✅ Height set to " << height << "\n";
        } else if (key == 'q') {
            break;
        }
    }

    stop_camera();
    std::cout << "🚪 Camera stopped. Exiting.\n";
    return 0;
}
