import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class RecognisePage extends StatefulWidget {
  @override
  _RecognisePageState createState() => _RecognisePageState();
}

class _RecognisePageState extends State<RecognisePage> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null) return;

    var request = http.MultipartRequest(
      'POST',
      // Uri.parse('https://your-api.com/upload'),
      Uri.parse('https://fr.whizzard.in/recognize'),
    );

    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        _image!.path,
        filename: basename(_image!.path),
      ),
    );

    var response = await request.send();
    print('fr status===${response.statusCode}');
    print('fr resp===${response}');

    if (response.statusCode == 200) {
      print('Image uploaded successfully');
    } else {
      print('Upload failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Facail Recoginsation")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _image != null
              ? Image.file(_image!, height: 200)
              : Text("No image selected"),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _pickImage,
            child: Text("Capture Image"),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: _uploadImage,
            child: Text("Upload Image API"),
          ),
        ],
      ),
    );
  }
}


















// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;
// import 'package:path/path.dart';
// import 'package:camera/camera.dart';
// import 'package:path_provider/path_provider.dart';

// import 'dart:async';


// class RecognisePageNew extends StatefulWidget {
//   @override
//   _RecognisePageNewState createState() => _RecognisePageNewState();
// }

// class _RecognisePageNewState extends State<RecognisePageNew> {
//   CameraController? _controller;
//   List<CameraDescription>? _cameras;
//   int _selectedCameraIndex = 0;
//   bool _isRecording = false;
//   int _recordSeconds = 0;
//   Timer? _timer;
//   XFile? _mediaFile;
//   bool _isUploading = false;

//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera();
//   }

//   Future<void> _initializeCamera() async {
//     _cameras = await availableCameras();
//     if (_cameras!.isNotEmpty) {
//       _controller = CameraController(
//           _cameras![_selectedCameraIndex], ResolutionPreset.high);
//       await _controller!.initialize();
//       if (mounted) setState(() {});
//     }
//   }

//   Future<void> _flipCamera() async {
//     if (_cameras == null || _cameras!.length < 2) return;

//     _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras!.length;
//     await _initializeCamera();
//   }

//   Future<void> _captureImage() async {
//     if (_controller == null || !_controller!.value.isInitialized) return;

//     final image = await _controller!.takePicture();
//     setState(() {
//       _mediaFile = image;
//     });

//     _uploadMedia(File(image.path), "image");
//   }

//   Future<void> _recordVideo() async {
//     if (_controller == null || !_controller!.value.isInitialized) return;

//     if (_isRecording) {
//       final video = await _controller!.stopVideoRecording();
//       _timer?.cancel();
//       setState(() {
//         _mediaFile = video;
//         _isRecording = false;
//         _recordSeconds = 0;
//       });

//       _uploadMedia(File(video.path), "video");
//     } else {
//       await _controller!.startVideoRecording();
//       _startTimer();
//       setState(() {
//         _isRecording = true;
//       });
//     }
//   }

//   void _startTimer() {
//     _recordSeconds = 0;
//     _timer = Timer.periodic(Duration(seconds: 1), (timer) {
//       setState(() {
//         _recordSeconds++;
//       });
//     });
//   }

//   Future<void> _uploadMedia(File file, String fileType) async {
//     int fileSizeInBytes = await file.length();
//     double fileSizeInMB = fileSizeInBytes / (1024 * 1024); // Convert to MB

//     print('File Size: ${fileSizeInMB.toStringAsFixed(2)} MB');

//     // ✅ Limit size (e.g., max 50MB for videos)
//     double maxVideoSizeMB = 50.0;
//     if (fileType == "video" && fileSizeInMB > maxVideoSizeMB) {
//       print("❌ Video file is too large! Limit is $maxVideoSizeMB MB.");
//       return; // Stop upload
//     }

//     setState(() {
//       _isUploading = true;
//     });

//     print('file====>${file}');

//     String url = fileType == 'video'
//         ? 'https://fr.whizzard.in/register_video'
//         : 'https://fr.whizzard.in/recognize';

//     print('url===>${url}');

//     var request = http.MultipartRequest(
//       'POST',
//       Uri.parse(url),
//     );

//     String fieldName = fileType == 'video' ? 'video' : 'image';
//     request.files.add(
//       await http.MultipartFile.fromPath(
//         fieldName,
//         file.path,
//         filename: basename(file.path),
//       ),
//     );

//     request.fields['name'] = 'Praveen Reddy';
//     request.fields['type'] = fileType; // Image or Video

//     var response = await request.send();

//     var responseBody = await response.stream.bytesToString();

//     debugPrint('statusCode=====>${response.statusCode}');
//     debugPrint('response=====>${responseBody}');

//     if (response.statusCode == 200) {
//       print('Upload successful');
//     } else {
//       print('Upload failed');
//     }

//     setState(() {
//       _isUploading = false;
//     });
//   }

//   @override
//   void dispose() {
//     _controller?.dispose();
//     _timer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Camera")),
//       body: Column(
//         children: [
//           // Camera preview at the top
//           Expanded(
//             flex: 3,
//             child: Stack(
//               children: [
//                 _controller != null && _controller!.value.isInitialized
//                     ? CameraPreview(_controller!)
//                     : Center(child: CircularProgressIndicator()),

//                 // Flip Camera Button (Top Right)
//                 Positioned(
//                   top: 20,
//                   right: 20,
//                   child: IconButton(
//                     icon: Icon(Icons.flip_camera_android,
//                         size: 30, color: Colors.white),
//                     onPressed: _flipCamera,
//                   ),
//                 ),

//                 // Video Recording Timer (Top Center)
//                 if (_isRecording)
//                   Positioned(
//                     top: 20,
//                     left: MediaQuery.of(context).size.width / 2 - 30,
//                     child: Container(
//                       padding:
//                           EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                       decoration: BoxDecoration(
//                         color: Colors.red,
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Text(
//                         "${_recordSeconds}s",
//                         style: TextStyle(
//                             color: Colors.white, fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),

//           // Preview of Captured Image
//           if (_mediaFile != null && !_isRecording)
//             Container(
//               height: 100,
//               margin: EdgeInsets.all(10),
//               child: Image.file(File(_mediaFile!.path)),
//             ),

//           // Uploading Indicator
//           if (_isUploading)
//             Padding(
//               padding: EdgeInsets.all(8.0),
//               child: Column(
//                 children: [
//                   CircularProgressIndicator(),
//                   SizedBox(height: 10),
//                   Text("Uploading..."),
//                 ],
//               ),
//             ),

//           // Buttons at the bottom
//           Expanded(
//             flex: 1,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     IconButton(
//                       icon: Icon(Icons.camera, size: 40),
//                       onPressed: _captureImage,
//                     ),
//                     SizedBox(width: 20),
//                     IconButton(
//                       icon: Icon(
//                         _isRecording ? Icons.stop : Icons.videocam,
//                         size: 40,
//                         color: _isRecording ? Colors.red : Colors.black,
//                       ),
//                       onPressed: _recordVideo,
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

