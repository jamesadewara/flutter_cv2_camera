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
      home: const CameraPage(),
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
  int flipCode = -2;
  int cameraWidth = 360;
  int cameraHeight = 520;

  final _formKey = GlobalKey<FormState>();
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();
  final _cameraIndexController = TextEditingController(text: "0");

  @override
  void initState() {
    super.initState();
    controller.setFlipCode(flipCode);
    _widthController.text = cameraWidth.toString();
    _heightController.text = cameraHeight.toString();
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

  void _showSwitchCameraForm() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Switch Camera",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _cameraIndexController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Camera Index (0 = default)",
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.switch_camera),
                  label: const Text("Switch"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                  ),
                  onPressed: () {
                    final idx = int.tryParse(_cameraIndexController.text) ?? 0;
                    controller.switchCamera(idx);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _switchCamera() {
    try {
      controller.switchCamera(1);
      debugPrint('Switched camera.');
    } catch (e) {
      debugPrint('Error switching camera: $e');
    }
  }

  void _showResolutionForm() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Set Camera Resolution",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _widthController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: "Width",
                          labelStyle: TextStyle(color: Colors.white70),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white24),
                          ),
                        ),
                        validator:
                            (v) =>
                                (v == null || v.isEmpty) ? "Enter width" : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _heightController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: "Height",
                          labelStyle: TextStyle(color: Colors.white70),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white24),
                          ),
                        ),
                        validator:
                            (v) =>
                                (v == null || v.isEmpty)
                                    ? "Enter height"
                                    : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text("Apply"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final width =
                          int.tryParse(_widthController.text) ?? cameraWidth;
                      final height =
                          int.tryParse(_heightController.text) ?? cameraHeight;
                      setState(() {
                        cameraWidth = width;
                        cameraHeight = height;
                      });
                      controller.setResolution(width: width, height: height);
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
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
    final isWide = MediaQuery.of(context).size.width > 600;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Cv2Camera(
              controller: controller,
              width: double.infinity,
              height: double.infinity,
              flipCode: flipCode,
              onFrame: (Cv2Frame frame) {},
            ),
          ),
          // Bottom action bar
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.camera,
                        color: Colors.white,
                        size: 32,
                      ),
                      onPressed: _takeAndSaveSnapshot,
                      tooltip: "Take Snapshot",
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(
                        Icons.flip_camera_android,
                        color: Colors.white,
                        size: 32,
                      ),
                      onPressed: _cycleFlip,
                      tooltip: "Flip Image",
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(
                        Icons.switch_camera,
                        color: Colors.white,
                        size: 32,
                      ),
                      onPressed: _showSwitchCameraForm,
                      tooltip: "Switch Camera",
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(
                        Icons.settings,
                        color: Colors.white,
                        size: 32,
                      ),
                      onPressed: _showResolutionForm,
                      tooltip: "Set Resolution",
                    ),
                    if (snapshot != null) ...[
                      const SizedBox(width: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(snapshot!, height: 48, width: 48),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton:
          isWide
              ? null
              : FloatingActionButton(
                onPressed: _switchCamera,
                backgroundColor: Colors.deepPurple,
                child: const Icon(Icons.switch_camera),
                tooltip: "Switch Camera",
              ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _cameraIndexController.dispose();
    super.dispose();
  }
}
