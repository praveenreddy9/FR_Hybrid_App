import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:image_gallery_saver/image_gallery_saver.dart'; // ✅ Alternative to gallery_saver
import 'package:http/http.dart' as http;

import '../../utility/Utils.dart';

class RecognisePageNew extends StatefulWidget {
  @override
  _RecognisePageNewState createState() => _RecognisePageNewState();
}

class _RecognisePageNewState extends State<RecognisePageNew> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isRecording = false;
  Timer? _timer;
  XFile? _mediaFile;
  bool _isUploading = false;
  int _recordSeconds = 0;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _showSnackBar(String message, BuildContext context, ColorCheck) {
    final snackBar = SnackBar(
        content: Text(message),
        backgroundColor: ColorCheck ? Colors.green : Colors.red,
        duration: Utils.returnStatusToastDuration(ColorCheck));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    CameraDescription frontCamera = _cameras!.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => _cameras!.first,
    );

    _controller = CameraController(frontCamera, ResolutionPreset.high);
    await _controller!.initialize();
    if (mounted) setState(() {});
  }

  Future<void> _captureImage() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    final image = await _controller!.takePicture();
    setState(() {
      _mediaFile = image;
    });

    // ✅ Save Image to Gallery
    // await ImageGallerySaver.saveFile(image.path);
    // print("✅ Image Saved to Gallery: ${image.path}");

    _uploadMedia(File(image.path), "image");
  }

  Future<void> _recordVideo() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    if (_isRecording) {
      final video = await _controller!.stopVideoRecording();
      _timer?.cancel();
      setState(() {
        _mediaFile = video;
        _isRecording = false;
      });

      // ✅ Save Video to Gallery
      // await ImageGallerySaver.saveFile(video.path);
      // print(" Video Saved to Gallery: ${video.path}");

      _uploadMedia(File(video.path), "video");
    } else {
      await _controller!.startVideoRecording();
      _startTimer();
      setState(() {
        _isRecording = true;
      });
    }
  }

  void _startTimer() {
    _recordSeconds = 0;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _recordSeconds++;
      });
    });
  }

  Future<void> _uploadMedia(File file, String fileType) async {
    int fileSizeInBytes = await file.length();
    double fileSizeInMB = fileSizeInBytes / (1024 * 1024); // Convert to MB

    print('File Size: ${fileSizeInMB.toStringAsFixed(2)} MB');

    // ✅ Limit size (e.g., max 50MB for videos)
    double maxVideoSizeMB = 50.0;
    if (fileType == "video" && fileSizeInMB > maxVideoSizeMB) {
      print(" Video file is too large! Limit is $maxVideoSizeMB MB.");
      return; // Stop upload
    }

    setState(() {
      _isUploading = true;
    });

    print('file====>${file}');

    String url = fileType == 'video'
        ? 'https://fr.whizzard.in/register'
        : 'https://fr.whizzard.in/recognize';

    print('url===>${url}');

    var request = http.MultipartRequest(
      'POST',
      Uri.parse(url),
    );

    String fieldName = fileType == 'video' ? 'video' : 'image';
    request.files.add(
      await http.MultipartFile.fromPath(
        fieldName,
        file.path,
        filename: basename(file.path),
      ),
    );

    request.fields['user_name'] = 'Mobile Face Test';
    request.fields['type'] = fileType; // Image or Video

    var response = await request.send();

    var responseBody = await response.stream.bytesToString();

    debugPrint('statusCode=====>${response.statusCode}');
    debugPrint('response=====>${responseBody}');

    if (response.statusCode == 200) {
      print('Upload successful');
    } else {
      print('Upload failed');
    }

    setState(() {
      _isUploading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text("Face Camera")),
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
                  if (_isRecording)
                    Positioned(
                      top: 20,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10)),
                        child: Text(
                          "${_recordSeconds}s",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (_mediaFile != null)
            Container(
              height: 100,
              margin: EdgeInsets.all(10),
              child: _mediaFile!.path.endsWith(".mp4")
                  ? Center(
                      child: Text(
                      "Video Recorded",
                      style: TextStyle(color: Colors.white),
                    ))
                  : Image.file(File(_mediaFile!.path)),
            ),
          if (_isUploading)
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text(
                    "Uploading...",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  Icons.camera,
                  size: 50,
                  color: Colors.white,
                ),
                onPressed: _captureImage,
              ),
              SizedBox(width: 20),
              IconButton(
                icon: Icon(
                  _isRecording ? Icons.stop : Icons.videocam,
                  size: 50,
                  color: _isRecording ? Colors.red : Colors.white,
                ),
                onPressed: _recordVideo,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
