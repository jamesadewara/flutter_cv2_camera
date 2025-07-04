import 'dart:ffi';
import 'package:flutter_cv2_camera/src/utils.dart';

/// The dynamic library instance used for FFI calls.
/// 
/// Loads the native library using [loadLibrary] from the utils.

final DynamicLibrary _lib = loadLibrary();

// FFI typedefs
typedef StartCameraC = Void Function();
typedef StopCameraC = Void Function();
typedef GetFrameC = Pointer<Uint8> Function(Pointer<Int32>);
typedef FreeFrameC = Void Function(Pointer<Uint8>);
typedef FlipcodeCameraC = Void Function(Int32);

class Cv2CameraBindings {
  static final void Function() startCamera =
      _lib.lookup<NativeFunction<StartCameraC>>('StartCamera').asFunction();

  static final void Function() stopCamera =
      _lib.lookup<NativeFunction<StopCameraC>>('StopCamera').asFunction();

  static final Pointer<Uint8> Function(Pointer<Int32>) getFrame =
      _lib.lookup<NativeFunction<GetFrameC>>('GetFrame').asFunction();

  static final void Function(Pointer<Uint8>) freeFrame =
      _lib.lookup<NativeFunction<FreeFrameC>>('FreeFrame').asFunction();

  static final void Function(int) flipCode =
      _lib
          .lookup<NativeFunction<FlipcodeCameraC>>('flipcode_camera')
          .asFunction();
}
