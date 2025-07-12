/// A custom Flutter plugin that bridges the power of OpenCV in C++ with real-time camera access.
///
/// This plugin enables real-time image streaming, frame analysis, and snapshot capturing,
/// making it ideal for AI/ML projects focused on computer vision.
library;

export 'src/cv2_camera_bindings.dart'
    if (dart.library.html) 'src/cv2_camera_web_bindings.dart';
export 'src/cv2_camera_controller.dart';
export 'src/cv2_camera_model.dart';
export 'src/cv2_camera_widget.dart';
