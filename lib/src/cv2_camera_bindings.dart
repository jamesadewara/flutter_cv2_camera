import 'dart:ffi';
import 'dart:io';
import 'package:path/path.dart' as path;

final libPath = path.join(Directory.current.path, 'build/linux/x64/debug/plugins/bundle/libflutter_cv2_camera_plugin.so');

void main() {
  print('Loading from: $libPath');
  print(File(libPath).existsSync());
}

final DynamicLibrary _lib = Platform.isLinux
    ?   DynamicLibrary.open(
        path.join(Directory.current.path, 'build/linux/x64/debug/plugins/bundle/libflutter_cv2_camera_plugin.so'))
    : throw UnsupportedError("Only Linux is supported currently");

// FFI typedefs
typedef StartCameraC = Void Function();
typedef StopCameraC = Void Function();
typedef GetFrameC = Pointer<Uint8> Function(Pointer<Int32>);
typedef FreeFrameC = Void Function(Pointer<Uint8>);
typedef FlipcodeCameraC = Void Function(Int32); 

class Cv2CameraBindings {
  static final void Function() startCamera = _lib
      .lookup<NativeFunction<StartCameraC>>('StartCamera')
      .asFunction();

  static final void Function() stopCamera = _lib
      .lookup<NativeFunction<StopCameraC>>('StopCamera')
      .asFunction();

  static final Pointer<Uint8> Function(Pointer<Int32>) getFrame = _lib
      .lookup<NativeFunction<GetFrameC>>('GetFrame')
      .asFunction();

  static final void Function(Pointer<Uint8>) freeFrame = _lib
      .lookup<NativeFunction<FreeFrameC>>('FreeFrame')
      .asFunction();

  static final void Function(int) flipCode = _lib
      .lookup<NativeFunction<FlipcodeCameraC>>('FlipcodeCamera')
      .asFunction();
}