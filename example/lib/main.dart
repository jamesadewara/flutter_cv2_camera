import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_cv2_camera/flutter_cv2_camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CV2 CAMERA Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home:  const CameraPage(),
    
    );
  }
}
class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  final controller = Cv2CameraController();
  Uint8List? snapshot;
  int flipCode = -2; // -2 = no flip

  @override
  void initState() {
    super.initState();
    controller.setFlipCode(flipCode);
  }

  void _cycleFlip() {
    setState(() {
      if (flipCode == -2) {
        flipCode = 0;
      } else if (flipCode == 0) {
        flipCode = 1;
      } else if (flipCode == 1) {
        flipCode = -1;
      } else {
        flipCode = -2;
      }
      controller.setFlipCode(flipCode);
    });
  }

  Future<void> _takeAndSaveSnapshot() async {
    final snap = await controller.takeSnap();
    if (snap == null) return;

    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'pictures');
    final fileName = 'frame_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final fullPath = p.join(path, fileName);

    await Directory(path).create(recursive: true);
    final file = File(fullPath);
    await file.writeAsBytes(snap);

    setState(() {
      snapshot = snap;
    });

    debugPrint('Saved snapshot to: $fullPath');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cv2 Camera')),
      body: Column(
        children: [
          Expanded(
            child: Cv2Camera(
              controller: controller,
              width: double.infinity,
              height: double.infinity,
              flipCode: flipCode,
              onFrame: (Cv2Frame frame) {
                debugPrint('New frame: ${frame.bytes.length} bytes');
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.black87,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: _takeAndSaveSnapshot,
                  icon: const Icon(Icons.camera),
                  label: const Text("Snapshot"),
                ),
                ElevatedButton.icon(
                  onPressed: _cycleFlip,
                  icon: const Icon(Icons.flip_camera_android),
                  label: const Text("Flip"),
                ),
                if (snapshot != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(snapshot!, height: 60, width: 60),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
