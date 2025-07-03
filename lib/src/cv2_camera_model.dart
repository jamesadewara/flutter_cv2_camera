import 'dart:convert' show base64Encode;
import 'dart:typed_data';

class Cv2Frame {
  final Uint8List bytes;
  final int flipCode;

  Cv2Frame(this.bytes, {this.flipCode = 0});

  // For serialization to send to a Python backend
  Map<String, dynamic> toJson() => {
        'data': bytes,
        'flip_code': flipCode,
      };

  // Convert to base64 string if needed for APIs
  String toBase64() => base64Encode(bytes);
}
