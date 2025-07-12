import 'dart:async';
import 'dart:ffi';
import 'package:ffi/ffi.dart' show calloc;
import 'package:flutter/foundation.dart';
import 'package:flutter_cv2_camera/flutter_cv2_camera.dart';
import 'package:flutter_cv2_camera/src/cv2_camera_web_bindings.dart';

/// Provides access to the camera controller, allowing for operations like
/// starting/stopping the camera, setting resolution, and accessing camera preview.
/// This file defines the Cv2CameraController class and related functionality
/// for managing camera operations in a Flutter application using the cv2_camera
/// This file defines the `Cv2CameraController` class, which manages camera operations
/// such as initialization, image capture, and resource management for the package.
///
/// The controller provides a high-level API to interact with device cameras,
/// handling platform-specific implementations and exposing methods for capturing
/// images, starting and stopping camera streams, and configuring camera settings.
///
/// This file is intended for internal use within the package and should not be
/// imported directly by package consumers. Instead, use the public API exposed
/// by the package.
///
/// For more information on usage and available features, refer to the package
/// documentation and example applications.

class Cv2CameraController {
  final _frameStream = StreamController<Cv2Frame>.broadcast();
  Timer? _framePoller;
  bool _isRunning = false;

  Stream<Cv2Frame> get frames => _frameStream.stream;

  Future<void> start() async {
    if (_isRunning) return;
    _isRunning = true;

    if (kIsWeb) {
      await Cv2CameraWebBindings.initialize();
      Cv2CameraWebBindings.startCamera();
    } else {
      Cv2CameraBindings.startCamera();
    }

    _framePoller = Timer.periodic(const Duration(milliseconds: 33), (_) async {
      final frameBytes = await _takeFrame();
      if (frameBytes != null) {
        _frameStream.add(Cv2Frame(frameBytes));
      }
    });
  }

  void stop() {
    _isRunning = false;
    _framePoller?.cancel();

    if (kIsWeb) {
      Cv2CameraWebBindings.stopCamera();
    } else {
      Cv2CameraBindings.stopCamera();
    }
  }

  Future<Uint8List?> takeSnap() async {
    return _takeFrame();
  }

  Future<Uint8List?> _takeFrame() async {
    if (kIsWeb) {
      return Cv2CameraWebBindings.getFrame()?.bytes;
    } else {
      final lenPtr = calloc<Int32>();
      final dataPtr = Cv2CameraBindings.getFrame(lenPtr);
      final len = lenPtr.value;
      calloc.free(lenPtr);

      if (len == 0 || dataPtr == nullptr) return null;

      final bytes = Uint8List.fromList(dataPtr.asTypedList(len));
      Cv2CameraBindings.freeFrame(dataPtr);
      return bytes;
    }
  }

  void setFlipCode(int code) {
    if (kIsWeb) {
      Cv2CameraWebBindings.flipCode(code);
    } else {
      Cv2CameraBindings.flipCode(code);
    }
  }

  void switchCamera(int index) {
    if (kIsWeb) {
      Cv2CameraWebBindings.switchCamera(index);
    } else {
      Cv2CameraBindings.switchCamera(index);
    }
  }

  void setResolution({required int width, required int height}) {
    if (kIsWeb) {
      Cv2CameraWebBindings.setResolution(width, height);
    } else {
      Cv2CameraBindings.setResolution(width, height);
    }
  }

  void dispose() {
    stop();
    _frameStream.close();
  }
}
