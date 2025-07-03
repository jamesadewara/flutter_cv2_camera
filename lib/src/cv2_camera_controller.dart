import 'dart:async';
import 'dart:ffi';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:flutter_cv2_camera/src/cv2_camera_bindings.dart';
import 'package:flutter_cv2_camera/src/cv2_camera_model.dart';

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
