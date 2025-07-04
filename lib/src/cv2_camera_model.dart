import 'dart:convert' show base64Encode;
import 'dart:typed_data';

class Cv2Frame {
  final Uint8List bytes;
  final int flipCode;

  Cv2Frame(this.bytes, {this.flipCode = 0});

  // For serialization to send to a Python backend
  /// Converts the current object to a JSON-compatible map.
  ///
  /// The returned map contains:
  /// - `'data'`: The byte data representing the object.
  /// - `'flip_code'`: The code indicating how the image should be flipped.
  ///
  /// This method is typically used for serialization, such as saving the object
  /// state or sending it over a network.
  ///
  /// Returns a `Map<String, dynamic>` representing the serialized object.
  Map<String, dynamic> toJson() => {'data': bytes, 'flip_code': flipCode};

  // Convert to base64 string if needed for APIs
  String toBase64() => base64Encode(bytes);
}
