import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_cv2_camera/flutter_cv2_camera.dart';

void main() {
  late Cv2CameraController controller;

  setUp(() {
    controller = Cv2CameraController();
  });

  tearDown(() {
    controller.dispose();
  });

  test('Controller can be instantiated and disposed', () {
    expect(controller, isA<Cv2CameraController>());
  });

  test('takeSnap returns null or valid data', () async {
    // This will depend on if native camera is available during test run
    try {
      controller.start();
      final snap = await controller.takeSnap();
      expect(snap, anyOf([isNull, isA<Uint8List>()]));
    } catch (e) {
      expect(e, isA<UnsupportedError>());
    }
  });
}
