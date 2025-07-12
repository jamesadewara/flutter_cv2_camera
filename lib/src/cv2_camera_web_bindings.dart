import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:js/js.dart';
import 'package:js/js_util.dart';

@JS('Cv2CameraWeb')
class Cv2CameraWeb {
  external factory Cv2CameraWeb();
  external Future<void> init();
  external void startCamera();
  external void stopCamera();
  external Uint8List? getFrame();
  external void flipCode(int code);
  external void setResolution(int width, int height);
  external void switchCamera(int index);
}

class Cv2CameraWebBindings {
  static Cv2CameraWeb? _instance;
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      await html.window.initCv2Camera();
      _instance = Cv2CameraWeb();
      await promiseToFuture(_instance!.init());
      _initialized = true;
    } catch (e) {
      debugPrint('Failed to initialize Cv2CameraWeb: $e');
      rethrow;
    }
  }

  static void startCamera() => _instance?.startCamera();
  static void stopCamera() => _instance?.stopCamera();

  static Uint8List? getFrame() {
    final bytes = _instance?.getFrame();
    return bytes != null ? Uint8List.fromList(bytes) : null;
  }

  static void flipCode(int code) => _instance?.flipCode(code);
  static void setResolution(int width, int height) =>
      _instance?.setResolution(width, height);
  static void switchCamera(int index) => _instance?.switchCamera(index);
}

extension on html.Window {
  Future<bool> initCv2Camera() async {
    if (hasProperty('initCv2Camera')) {
      return promiseToFuture(jsify(callMethod('initCv2Camera', [])));
    }
    throw Exception('Cv2CameraWeb not loaded');
  }
}
