# flutter\_cv2\_camera

**version 0.0.2**

A custom Flutter plugin that bridges the power of OpenCV in C++ with real-time camera access in Flutter. Designed to enable real-time image streaming, frame analysis, and snapshot capturing—perfect for AI/ML projects focused on computer vision.

> 🚀 Currently available on **Linux** with upcoming support for **Web**, **Android**, **Windows**, **macOS**, and **iOS** in weekly updates.

---

## ✨ Why I Built This

As a developer passionate about AI and computer vision, I constantly faced a pain point: **lack of a cross-platform real-time camera plugin that works seamlessly with OpenCV and Flutter**.

Most camera plugins are either platform-limited or lack direct access to frame buffers required for AI/ML models. So, I decided to step up and build my own solution — one that combines the low-level power of C++ OpenCV with the flexibility of Flutter.

If you work with mobile or edge AI, this is the plugin you've been waiting for.

---

## ✅ Features

* 🔧 Real-time camera feed powered by C++ OpenCV.
* 🎯 `Cv2Camera` widget to render frames in your Flutter app.
* 🔄 Frame subscription via `onFrame` (NumPy-array format).
* 🖼️ Access raw image bytes via `onByte`.
* 📸 Snapshots with `onSnap` — save or analyze.
* 🔄 Flip camera feed (horizontal/vertical/both).
* 📐 Dynamically change resolution.
* 🔁 Switch between available cameras by index.
* 🔌 Built with FFI and native C++.
* 💻 **Linux supported** now. Cross-platform rollout coming **weekly**.

---

## 🚀 Getting Started

1. Add to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_cv2_camera: ^0.0.2
```

2. Linux prerequisites:

   * Make sure you have OpenCV (`opencv4`) installed.
   * CMake >= 3.10.

3. Your Flutter app must run on Linux for now:

   ```bash
   flutter run -d linux
   ```

> Windows, Web, and Android support will be added soon — follow the repo for updates.

---

## 🛠️ Usage

### Basic Setup

```dart
final controller = Cv2CameraController();

Cv2Camera(
  controller: controller,
  onFrame: (frame) {
    // Access as NumPy array (Uint8List)
    processFrame(frame.bytes);
  },
  onByte: (bytes) {
    // Save or stream
    upload(bytes);
  },
  flipCode: 0, // vertical: 0, horizontal: 1, both: -1
  width: 300,
  height: 250,
);
```

---

### 📸 Capture a Snapshot

```dart
final bytes = await controller.takeSnap();
// Save or analyze
```

---

### 🔁 Switch Camera (by index)

```dart
// Switch to camera 1
await controller.switchCamera(1);

// Back to default (camera 0)
await controller.switchCamera(0);
```

---

### 📐 Set Camera Resolution

```dart
// Set resolution to 640x480
await controller.setResolution(width: 640, height: 480);
```

---

## 📷 Screenshots / Demo

<div align="center">
  <img src="screenshots/Screenshot from 2025-07-04 19-07-02.png" width="60%" />
  <br/><br/>
  <iframe width="560" height="315" src="https://www.youtube.com/embed/YLmcxVz2lYQ" frameborder="0" allowfullscreen></iframe>
</div>

---

## 🤝 Contributing

I would love collaborators! If you:

* ❤️ OpenCV
* 💡 Know Flutter + C++
* 🧠 Love AI or mobile edge computing

Let’s build the future of mobile-first AI vision systems together. PRs and issues are highly welcome.

---

## 🔮 Roadmap

* ✅ Linux support
* 🔜 Web support
* 🔜 Android support
* 🔜 Windows support
* 🔜 macOS & iOS

---

## 📩 Stay Updated

Follow me on [LinkedIn](https://www.linkedin.com/in/james-adewara-b0b955290/) or GitHub for weekly updates.

---

## License

[MIT](LICENSE)