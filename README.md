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
* 📸 Snapshots with `takeSnap()` — save or analyze.
* ↔️ Flip camera feed (horizontal/vertical/both).
* 📐 Resize camera view with custom width & height.
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

> Support for Web, Android, and Windows coming **soon** — stay tuned.

---

## 🛠️ Usage

### 📸 Initialize and render the camera

```dart
final controller = Cv2CameraController();

Cv2Camera(
  controller: controller,
  onFrame: (frame) {
    // Frame as NumPy-style array (Uint8List)
    print("Received frame of ${frame.bytes.length} bytes");
  },
  onByte: (bytes) {
    // Raw JPEG bytes - e.g. for uploading
    print("Image byte length: ${bytes.length}");
  },
  flipCode: 0, // 0 = vertical, 1 = horizontal, -1 = both, -2 = no flip
  width: 300,  // resize camera preview
  height: 250,
);
```

---

### 📂 Take a snapshot

```dart
final imageBytes = await controller.takeSnap();
if (imageBytes != null) {
  // Save, analyze or upload
  print("Captured image of ${imageBytes.length} bytes");
}
```

---

### 🔄 Flip camera feed

```dart
controller.setFlipCode(-1); // Flip both axes
```

---

### 🧠 Send to Python backend

You can easily send the frame to your backend using the `toJson()` or `toBase64()`:

```dart
Cv2Frame frame = Cv2Frame(bytes);
String base64Data = frame.toBase64();
```

---

## 📷 Screenshots / Demo

<div align="center">
  <img src="screenshots/Screenshot from 2025-07-04 19-07-02.png" width="400" />
  <br /><br />
  <a href="https://youtu.be/YLmcxVz2lYQ" target="_blank">
    ▶️ Watch the Demo on YouTube
  </a>
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
* 🔜 Web support (WASM + JS glue)
* 🔜 Android support
* 🔜 Windows support
* 🔜 macOS & iOS

---

## 📩 Stay Updated

Follow me on [LinkedIn](https://www.linkedin.com/in/james-adewara-b0b955290/) or GitHub for weekly updates.

---

## License

[MIT](LICENSE)