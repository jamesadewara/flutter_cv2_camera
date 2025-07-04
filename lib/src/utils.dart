import 'dart:ffi';
import 'dart:io';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:path/path.dart' as path;

String getLibraryPath() {
  List<String> possiblePaths;
  
  if (Platform.isLinux) {
    possiblePaths = [
      // Built library locations (most common)
      'build/linux/x64/debug/bundle/lib/libflutter_cv2_camera_plugin.so',
      'build/linux/x64/release/bundle/lib/libflutter_cv2_camera_plugin.so',
      
      // Alternative build locations
      'build/linux/x64/debug/lib/libflutter_cv2_camera_plugin.so',
      'build/linux/x64/release/lib/libflutter_cv2_camera_plugin.so',
      
      // Development plugin locations (if they exist)
      'linux/flutter/ephemeral/.plugin_symlinks/flutter_cv2_camera_plugin/linux/libflutter_cv2_camera_plugin.so',
      
      // System library fallback (for distributed apps)
      'lib/libflutter_cv2_camera_plugin.so',
    ];
  } else if (Platform.isWindows) {
    possiblePaths = [
      'build/windows/x64/runner/Debug/flutter_cv2_camera_plugin.dll',
      'build/windows/x64/runner/Release/flutter_cv2_camera_plugin.dll',
      'build/windows/runner/Debug/flutter_cv2_camera_plugin.dll',
      'build/windows/runner/Release/flutter_cv2_camera_plugin.dll',
      'windows/flutter/ephemeral/.plugin_symlinks/flutter_cv2_camera_plugin/windows/flutter_cv2_camera_plugin.dll',
    ];
  } else if (Platform.isMacOS) {
    possiblePaths = [
      'build/macos/Build/Products/Debug/flutter_cv2_camera_plugin.framework/flutter_cv2_camera_plugin',
      'build/macos/Build/Products/Release/flutter_cv2_camera_plugin.framework/flutter_cv2_camera_plugin',
      'macos/flutter/ephemeral/.plugin_symlinks/flutter_cv2_camera_plugin/macos/flutter_cv2_camera_plugin.framework/flutter_cv2_camera_plugin',
    ];
  } else {
    throw UnsupportedError('Platform ${Platform.operatingSystem} is not supported');
  }

  for (final relativePath in possiblePaths) {
    final fullPath = path.join(Directory.current.path, relativePath);
    debugPrint('Checking: $fullPath'); // Debug print
    if (File(fullPath).existsSync()) {
      debugPrint('Found library at: $fullPath');
      return fullPath;
    }
  }
  
  // If no file found, list what's actually in the expected directory
  final debugBundleLib = path.join(Directory.current.path, 'build/linux/x64/debug/bundle/lib');
  if (Directory(debugBundleLib).existsSync()) {
    debugPrint('Contents of $debugBundleLib:');
    Directory(debugBundleLib).listSync().forEach((file) {
      debugPrint('  - ${file.path}');
    });
  }
  
  throw Exception('Could not find flutter_cv2_camera_plugin library in any expected location for ${Platform.operatingSystem}');
}

DynamicLibrary loadLibrary() {
  if (Platform.isLinux) {
    try {
      // Try loading from system/Flutter's plugin location first
      return DynamicLibrary.open('libflutter_cv2_camera_plugin.so');
    } catch (e) {
      // Fallback to manual path resolution
      return DynamicLibrary.open(getLibraryPath());
    }
  } else if (Platform.isWindows) {
    try {
      return DynamicLibrary.open('flutter_cv2_camera_plugin.dll');
    } catch (e) {
      return DynamicLibrary.open(getLibraryPath());
    }
  } else if (Platform.isMacOS) {
    try {
      return DynamicLibrary.open('flutter_cv2_camera_plugin.framework/flutter_cv2_camera_plugin');
    } catch (e) {
      return DynamicLibrary.open(getLibraryPath());
    }
  } else {
    throw UnsupportedError('Platform ${Platform.operatingSystem} is not supported');
  }
}