import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../controllers/progress_controller.dart';

class AiPoseCameraScreen extends StatefulWidget {
  const AiPoseCameraScreen({super.key});

  @override
  State<AiPoseCameraScreen> createState() => _AiPoseCameraScreenState();
}

class _AiPoseCameraScreenState extends State<AiPoseCameraScreen> {
  final ProgressController controller = Get.find();
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  
  final PoseDetector _poseDetector = PoseDetector(options: PoseDetectorOptions());
  bool _isReady = false;
  bool _isBusy = false;
  
  bool _isMatched = false;
  int _countdown = 3;
  Timer? _countdownTimer;
  
  Pose? _currentPose;
  Pose? _targetPose;
  int _cameraIndex = 0;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _loadTargetPose();
  }

  void _loadTargetPose() {
    _targetPose = null; 
  }

  Future<void> _initCamera() async {
    cameras = await availableCameras();
    if (cameras != null && cameras!.isNotEmpty) {
      await _setupCameraController(cameras![_cameraIndex]);
    }
  }

  Future<void> _setupCameraController(CameraDescription cameraDescription) async {
    setState(() {
      _isReady = false;
    });
    if (_cameraController != null) {
      await _cameraController!.stopImageStream();
      await _cameraController!.dispose();
    }
    _cameraController = CameraController(
      cameraDescription, 
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid 
          ? ImageFormatGroup.nv21 
          : ImageFormatGroup.bgra8888,
    );
    try {
      await _cameraController!.initialize();
      if (mounted) {
        setState(() {
          _isReady = true;
        });
        _cameraController!.startImageStream(_processCameraImage);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _toggleCamera() async {
    if (cameras == null || cameras!.isEmpty) return;
    _cameraIndex = (_cameraIndex + 1) % cameras!.length;
    await _setupCameraController(cameras![_cameraIndex]);
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_isBusy) return;
    _isBusy = true;

    try {
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());
      final camera = cameras![_cameraIndex];
      final imageRotation = InputImageRotationValue.fromRawValue(camera.sensorOrientation) ?? InputImageRotation.rotation0deg;
      final inputImageFormat = InputImageFormatValue.fromRawValue(image.format.raw) ?? InputImageFormat.nv21;

      final inputImageData = InputImageMetadata(
        size: imageSize,
        rotation: imageRotation,
        format: inputImageFormat,
        bytesPerRow: image.planes[0].bytesPerRow,
      );

      final inputImage = InputImage.fromBytes(bytes: bytes, metadata: inputImageData);
      final poses = await _poseDetector.processImage(inputImage);

      if (poses.isNotEmpty) {
        _currentPose = poses.first;
        _checkPoseAlignment();
      } else {
        _currentPose = null;
        _resetCountdown();
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      _isBusy = false;
      if (mounted) setState(() {});
    }
  }

  void _checkPoseAlignment() {
    if (_currentPose == null) return;

    bool isAligned = _calculateSimilarity(_currentPose!, _targetPose);

    if (isAligned && !_isMatched) {
      setState(() {
        _isMatched = true;
      });
      _startAutoCapture();
    } else if (!isAligned && _isMatched) {
      _resetCountdown();
    }
  }

  bool _calculateSimilarity(Pose current, Pose? target) {
    final leftShoulder = current.landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = current.landmarks[PoseLandmarkType.rightShoulder];
    final leftHip = current.landmarks[PoseLandmarkType.leftHip];
    final rightHip = current.landmarks[PoseLandmarkType.rightHip];

    if (leftShoulder == null || rightShoulder == null || leftHip == null || rightHip == null) {
      return false;
    }

    if (leftShoulder.likelihood < 0.7 || rightShoulder.likelihood < 0.7 || 
        leftHip.likelihood < 0.7 || rightHip.likelihood < 0.7) {
      return false;
    }

    final dx = (leftShoulder.x - rightShoulder.x).abs();
    final dy = (leftShoulder.y - rightShoulder.y).abs();
    
    if (dy > dx * 0.15) return false;

    return true;
  }

  void _startAutoCapture() {
    _countdown = 3;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!_isMatched) {
        timer.cancel();
        return;
      }

      if (_countdown > 1) {
        setState(() {
          _countdown--;
        });
      } else {
        timer.cancel();
        await _captureImage();
      }
    });
  }

  void _resetCountdown() {
    _countdownTimer?.cancel();
    if (mounted) {
      setState(() {
        _isMatched = false;
        _countdown = 3;
      });
    }
  }

  Future<void> _captureImage() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      await _cameraController!.stopImageStream();
      try {
        XFile file = await _cameraController!.takePicture();
        Get.back();
        List<Map<String, dynamic>>? poseData;
        if (_currentPose != null) {
          poseData = _currentPose!.landmarks.values.map((lm) => {
            'type': lm.type.index,
            'x': lm.x,
            'y': lm.y,
            'likelihood': lm.likelihood,
          }).toList();
        }
        controller.uploadAndSavePhoto(file.path, poseData: poseData);
      } catch (e) {
        debugPrint(e.toString());
        if (mounted) {
          _cameraController!.startImageStream(_processCameraImage);
        }
      }
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _cameraController?.stopImageStream();
    _cameraController?.dispose();
    _poseDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_isReady && _cameraController != null)
            CameraPreview(_cameraController!)
          else
            const Center(child: CircularProgressIndicator(color: Colors.white)),

          if (_isReady && _currentPose != null)
            CustomPaint(
              painter: PosePainter(_currentPose!, _isMatched),
            ),

          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: _isMatched ? Colors.green.withValues(alpha: 0.8) : Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _isMatched ? 'Giữ nguyên! Đang tự động chụp...' : 'Hãy căn chỉnh cơ thể vào giữa khung',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                if (_isMatched)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      '$_countdown',
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 80,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Get.back(),
                ),
                GestureDetector(
                  onTap: _captureImage,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _isMatched ? Colors.greenAccent : Colors.white, 
                        width: _isMatched ? 8 : 4
                      ),
                      color: _isMatched 
                          ? Colors.green.withValues(alpha: 0.5) 
                          : Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.flip_camera_ios, color: Colors.white, size: 30),
                  onPressed: _toggleCamera,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PosePainter extends CustomPainter {
  final Pose pose;
  final bool isMatched;

  PosePainter(this.pose, this.isMatched);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isMatched ? Colors.greenAccent : Colors.white
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = isMatched ? Colors.green : Colors.redAccent
      ..style = PaintingStyle.fill;

    for (final landmark in pose.landmarks.values) {
      if (landmark.likelihood > 0.6) {
        canvas.drawCircle(Offset(landmark.x, landmark.y), 6, dotPaint);
      }
    }

    void drawLine(PoseLandmarkType type1, PoseLandmarkType type2) {
      final landmark1 = pose.landmarks[type1];
      final landmark2 = pose.landmarks[type2];
      if (landmark1 != null && landmark2 != null && 
          landmark1.likelihood > 0.6 && landmark2.likelihood > 0.6) {
        canvas.drawLine(Offset(landmark1.x, landmark1.y), Offset(landmark2.x, landmark2.y), paint);
      }
    }

    drawLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder);
    drawLine(PoseLandmarkType.leftHip, PoseLandmarkType.rightHip);
    drawLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip);
    drawLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip);
    drawLine(PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee);
    drawLine(PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee);
    drawLine(PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle);
    drawLine(PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle);
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.pose != pose || oldDelegate.isMatched != isMatched;
  }
}
