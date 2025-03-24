import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
// import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceCaptureScreen extends StatefulWidget {
  @override
  _FaceCaptureScreenState createState() => _FaceCaptureScreenState();
}

class _FaceCaptureScreenState extends State<FaceCaptureScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isDetecting = false;
  FaceDetector _faceDetector = GoogleMlKit.vision.faceDetector();
  List<Face> _faces = [];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _faceDetector.close();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    CameraDescription frontCamera = _cameras!.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => _cameras!.first,
    );

    _controller = CameraController(frontCamera, ResolutionPreset.medium);
    await _controller!.initialize();
    if (mounted) setState(() {});
    _startFaceDetection();
  }

  void _startFaceDetection() {
    _controller!.startImageStream((CameraImage image) async {
      if (_isDetecting) return;
      _isDetecting = true;

      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final inputImage = InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.nv21,
          bytesPerRow: image.planes[0].bytesPerRow,
        ),
      );

      final List<Face> faces = await _faceDetector.processImage(inputImage);
      setState(() {
        _faces = faces;
      });

      _isDetecting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text("Face Recognition")),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_controller != null && _controller!.value.isInitialized)
                    ClipOval(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: CameraPreview(_controller!),
                      ),
                    )
                  else
                    CircularProgressIndicator(),
                  ..._faces.map((face) {
                    return Positioned(
                      top: face.boundingBox.top,
                      left: face.boundingBox.left,
                      child: Container(
                        width: face.boundingBox.width,
                        height: face.boundingBox.height,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.green, width: 3),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
