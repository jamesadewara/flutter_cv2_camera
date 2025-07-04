import 'dart:async';
import 'dart:ffi';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:flutter_cv2_camera/src/cv2_camera_bindings.dart';
import 'package:flutter_cv2_camera/src/cv2_camera_model.dart';

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

  void start() {
    if (_isRunning) return;
    _isRunning = true;
    Cv2CameraBindings.startCamera();
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
    Cv2CameraBindings.stopCamera();
  }

  Future<Uint8List?> takeSnap() async {
    return _takeFrame();
  }

  Future<Uint8List?> _takeFrame() async {
    final lenPtr = calloc<Int32>();
    final dataPtr = Cv2CameraBindings.getFrame(lenPtr);
    final len = lenPtr.value;
    calloc.free(lenPtr);

    if (len == 0 || dataPtr == nullptr) return null;

    final bytes = Uint8List.fromList(dataPtr.asTypedList(len));
    Cv2CameraBindings.freeFrame(dataPtr);
    return bytes;
  }

  void setFlipCode(int code) {
    Cv2CameraBindings.flipCode(code);
  }

  void dispose() {
    stop();
    _frameStream.close();
  }
}
