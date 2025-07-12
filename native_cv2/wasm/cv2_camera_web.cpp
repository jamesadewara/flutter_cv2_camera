#include <emscripten.h>
#include <emscripten/bind.h>
#include <emscripten/val.h>
#include <vector>
#include <cstdint>
#include <iostream>

using namespace emscripten;

// Forward declarations with C linkage for EMSCRIPTEN_KEEPALIVE functions
extern "C" {
    void EMSCRIPTEN_KEEPALIVE onOpenCVReady();
    void EMSCRIPTEN_KEEPALIVE onCameraStarted(val stream);
    void EMSCRIPTEN_KEEPALIVE onCameraError(val error);
}

// Regular C++ forward declarations
void stopCamera();

// Global state
static val cv = val::global("cv");
static val videoElement = val::global("document").call<val>("createElement", val("video"));
static val canvas = val::global("document").call<val>("createElement", val("canvas"));
static val ctx = canvas.call<val>("getContext", val("2d"));
static int flipCode = -1;
static bool isRunning = false;
static int cameraIndex = 0;
static int width = 640;
static int height = 480;

// Implementation of C-linked functions
extern "C" void EMSCRIPTEN_KEEPALIVE onOpenCVReady() {
    std::cout << "OpenCV.js is ready!" << std::endl;
}

extern "C" void EMSCRIPTEN_KEEPALIVE onCameraStarted(val stream) {
    videoElement.set("srcObject", stream);
    videoElement.call<void>("play");
    isRunning = true;
    std::cout << "Camera started successfully" << std::endl;
}

extern "C" void EMSCRIPTEN_KEEPALIVE onCameraError(val error) {
    std::cerr << "Camera error: " << error.call<std::string>("toString").c_str() << std::endl;
}

// Stop camera capture
void stopCamera() {
    if (!isRunning) return;
    
    val stream = videoElement["srcObject"];
    if (!stream.isUndefined() && !stream.isNull()) {
        val tracks = stream.call<val>("getTracks");
        tracks.call<void>("forEach", val::global("Function").new_(val("track"), val("track.stop()")));
    }
    videoElement.set("srcObject", val::null());
    isRunning = false;
    emscripten_cancel_main_loop();
}

// Initialize OpenCV and camera
void initOpenCV() {
    // Wait for OpenCV to be ready
    cv["onRuntimeInitialized"].call<void>("then", val::module_property("onOpenCVReady"));
}

// Start camera capture
void startCamera(int w, int h, int index) {
    if (isRunning) stopCamera();

    width = w;
    height = h;
    cameraIndex = index;

    val constraints = val::object();
    val videoConstraints = val::object();
    videoConstraints.set("width", width);
    videoConstraints.set("height", height);
    videoConstraints.set("facingMode", cameraIndex == 0 ? "user" : "environment");
    constraints.set("video", videoConstraints);

    val navigator = val::global("navigator");
    val mediaDevices = navigator["mediaDevices"];

    mediaDevices.call<val>("getUserMedia", constraints)
        .call<val>("then", val::module_property("onCameraStarted"))
        .call<val>("catch", val::module_property("onCameraError"));
}

// Capture and process frame
val getFrame() {
    if (!isRunning) return val::null();

    // Set canvas size
    canvas.set("width", width);
    canvas.set("height", height);
    
    // Draw video frame to canvas
    ctx.call<void>("drawImage", videoElement, 0, 0, width, height);
    
    // Get image data
    val imageData = ctx.call<val>("getImageData", 0, 0, width, height);
    val data = imageData["data"];
    
    // Create OpenCV Mat from image data
    val src = cv.call<val>("Mat", height, width, cv["CV_8UC4"]);
    val dataPtr = src.call<val>("data");
    val uint8Array = val::global("Uint8Array").new_(dataPtr["byteLength"].as<unsigned>(), dataPtr);
    uint8Array.call<void>("set", data);
    
    // Convert to BGR
    val dst = cv.call<val>("Mat");
    cv.call<void>("cvtColor", src, dst, cv["COLOR_RGBA2BGR"]);
    
    // Flip if needed
    if (flipCode >= 0) {
        val flipped = cv.call<val>("Mat");
        cv.call<void>("flip", dst, flipped, flipCode);
        dst = flipped;
    }
    
    // Encode as JPEG
    val encoded = val::global("Array").new_();
    cv.call<void>("imencode", val(".jpg"), dst, encoded, val::global("Array").new_(cv["IMWRITE_JPEG_QUALITY"], 90));
    
    // Convert to Uint8Array
    val encodedArray = encoded.call<val>("at", 0);
    val result = val::global("Uint8Array").new_(encodedArray["byteLength"].as<unsigned>(), encodedArray);
    
    // Clean up
    src.call<void>("delete");
    dst.call<void>("delete");
    
    return result;
}

// Set camera resolution
void setResolution(int w, int h) {
    width = w;
    height = h;
    if (isRunning) {
        stopCamera();
        startCamera(width, height, cameraIndex);
    }
}

// Switch between cameras
void switchCamera(int index) {
    cameraIndex = index;
    if (isRunning) {
        stopCamera();
        startCamera(width, height, cameraIndex);
    }
}

// Set flip code (0=vertical, 1=horizontal, -1=both)
void setFlipCode(int code) {
    flipCode = code;
}

EMSCRIPTEN_BINDINGS(cv2_camera) {
    function("initOpenCV", &initOpenCV);
    function("startCamera", &startCamera);
    function("stopCamera", &stopCamera);
    function("getFrame", &getFrame);
    function("setResolution", &setResolution);
    function("switchCamera", &switchCamera);
    function("setFlipCode", &setFlipCode);
}