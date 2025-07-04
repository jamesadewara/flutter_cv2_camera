# Changelog

All notable changes to this project will be documented in this file.

This project follows [semantic versioning](https://semver.org/).

---

## [0.0.1] - 2025-07-03

### ✨ Added
- Initial release of `flutter_cv2_camera` plugin.
- Linux platform support with OpenCV C++ integration.
- Real-time camera feed rendering using `Cv2Camera` widget.
- `onFrame` callback: stream frames as NumPy-compatible `Uint8List`.
- `onByte` callback: access raw image bytes.
- `onSnap` method: capture snapshots for saving or analysis.
- Flip camera feed (horizontal, vertical, or both).
- Example project with working Linux demo.
- Full documentation and usage guide in `README.md`.
- MIT License and open contribution model.

---

### 🛤 Coming Soon (in future versions)
- ✅ Web support
- ✅ Android support
- ✅ Windows support
- ✅ macOS & iOS support
- Improved UI fallback rendering (`Image.memory`, `RawImage`, `CustomPaint`)
- Performance optimizations for real-time image processing

---

