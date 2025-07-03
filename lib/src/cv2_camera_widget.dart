import 'dart:async' show StreamSubscription;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_cv2_camera/flutter_cv2_camera.dart';

class Cv2Camera extends StatefulWidget {
  final Cv2CameraController controller;
  final void Function(Cv2Frame frame)? onFrame;
  final void Function(Uint8List bytes)? onByte;
  final int flipCode;
  final double? width;
  final double? height;

  const Cv2Camera({
    super.key,
    required this.controller,
    this.onFrame,
    this.onByte,
    this.flipCode = 0,
    this.width,
    this.height,
  });

  @override
  State<Cv2Camera> createState() => _Cv2CameraState();
}

class _Cv2CameraState extends State<Cv2Camera> {
  Uint8List? _currentFrame;
  late final StreamSubscription _sub;

  @override
  void initState() {
    super.initState();
    widget.controller.setFlipCode(widget.flipCode);
    _sub = widget.controller.frames.listen((frame) {
      if (!mounted) return;

      setState(() => _currentFrame = frame.bytes);
      widget.onFrame?.call(frame);
      widget.onByte?.call(frame.bytes);
    });
    widget.controller.start();
  }

  @override
  void dispose() {
    _sub.cancel();
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentFrame == null) {
      return const Center(child: CircularProgressIndicator());
    }

    Widget imageWidget;
    try {
      imageWidget = Image.memory(_currentFrame!, gaplessPlayback: true);
    } catch (_) {
      try {
        // Fallback to Image.memory if the first try fails
        imageWidget = Image.memory(
          _currentFrame!,
          fit: BoxFit.cover,
          gaplessPlayback: true,
        );
      } catch (_) {
        imageWidget = CustomPaint(painter: _FallbackPainter(_currentFrame!));
      }
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: imageWidget,
    );
  }
}

class _FallbackPainter extends CustomPainter {
  final Uint8List bytes;
  _FallbackPainter(this.bytes);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;
    canvas.drawRect(Offset.zero & size, paint);
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Failed to render frame',
        style: TextStyle(color: Colors.white),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(10, 10));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
