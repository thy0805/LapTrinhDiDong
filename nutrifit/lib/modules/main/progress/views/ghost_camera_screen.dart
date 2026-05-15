import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import '../controllers/progress_controller.dart';

class GhostCameraScreen extends StatefulWidget {
  const GhostCameraScreen({super.key});

  @override
  State<GhostCameraScreen> createState() => _GhostCameraScreenState();
}

class _GhostCameraScreenState extends State<GhostCameraScreen> {
  final ProgressController controller = Get.find();
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    cameras = await availableCameras();
    if (cameras != null && cameras!.isNotEmpty) {
      _cameraController = CameraController(cameras![0], ResolutionPreset.high);
      await _cameraController!.initialize();
      if (mounted) {
        setState(() {
          _isReady = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Lớp Camera Thật ở dưới cùng
          if (_isReady && _cameraController != null)
            CameraPreview(_cameraController!)
          else
            const Center(child: CircularProgressIndicator(color: Colors.white)),

          // 2. Lớp Ảnh Bóng Ma (Ghosting) đè lên trên
          Obx(() {
            if (controller.lastPhotoUrl.value.isNotEmpty) {
              return Opacity(
                opacity: 0.3, // Độ mờ 30% để nhìn xuyên thấu
                child: Image.network(
                  controller.lastPhotoUrl.value,
                  fit: BoxFit.cover, // Căng full màn hình cho khớp khung
                ),
              );
            }
            return const SizedBox.shrink(); // Nếu chưa có ảnh cũ thì không hiện bóng
          }),

          // 3. UI Nút Chụp Ảnh
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
                  onTap: () async {
                    if (_cameraController != null && _cameraController!.value.isInitialized) {
                      XFile file = await _cameraController!.takePicture();
                      Get.back(); // Đóng camera
                      controller.uploadAndSavePhoto(file.path); // Gọi hàm lưu ảnh
                    }
                  },
                  child: Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.flip_camera_ios, color: Colors.white, size: 30),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
