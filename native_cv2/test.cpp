#include "cv2_camera.hpp"
#include <opencv2/opencv.hpp>
#include <iostream>
#include <thread>
#include <chrono>
#include <filesystem>

namespace fs = std::filesystem;

int main() {
    start_camera();
    std::cout << "Camera started. Press 's' to take a picture, 'f' to flip, 'q' to quit.\n";

    // Ensure the output directory exists
    fs::create_directories("pics");

    cv::Mat img;
    int frameCount = 0;
    int flipCode = -2; // Initial: no flip
    flipcode_camera(flipCode); // apply initial state

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

        char key = (char)cv::waitKey(30); // Wait 30ms for a key press

        if (key == 's') {
            std::string filename = "pics/frame_" + std::to_string(frameCount++) + ".jpg";
            if (!img.empty()) {
                cv::imwrite(filename, img);
                std::cout << "Saved: " << filename << "\n";
            }
        } else if (key == 'q') {
            break;
        } else if (key == 'f') {
            // Cycle flipCode: -2 → 0 → 1 → -1 → -2 ...
            if (flipCode == -2) {
                flipCode = 0; // Vertical flip
            } else if (flipCode == 0) {
                flipCode = 1; // Horizontal flip
            } else if (flipCode == 1) {
                flipCode = -1; // Both
            } else {
                flipCode = -2; // No flip
            }
            flipcode_camera(flipCode);
            std::cout << "FlipCode changed to: " << flipCode << "\n";
        }
    }

    stop_camera();
    std::cout << "Camera stopped. Exiting.\n";
    return 0;
}
