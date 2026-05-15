import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/progress_controller.dart';
import 'progress_comparison_screen.dart';

class ProgressGalleryScreen extends StatelessWidget {
  const ProgressGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProgressController controller = Get.put(ProgressController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Tiến độ tập luyện', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: 'Poppins', fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.black), onPressed: () => Get.back()),
        actions: [
          TextButton.icon(
            onPressed: () => Get.to(() => ProgressComparisonScreen()),
            icon: const Icon(Icons.compare, color: Color(0xFFC050F6)),
            label: const Text('So sánh', style: TextStyle(color: Color(0xFFC050F6), fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
          )
        ],
      ),
      body: Obx(() {
        if (controller.progressPhotos.isEmpty) {
          return const Center(
            child: Text(
              'Chưa có ảnh tiến độ nào.\nHãy thêm bức ảnh đầu tiên của bạn!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFB6B4C1),
                fontSize: 14,
                fontFamily: 'Poppins',
              ),
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(20.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 0.7, // Ảnh chân dung nhìn sẽ đẹp hơn
          ),
          itemCount: controller.progressPhotos.length,
          itemBuilder: (context, index) {
            var photoData = controller.progressPhotos[index];
            return GestureDetector(
              onLongPress: () => controller.deletePhoto(photoData['id']),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: NetworkImage(photoData['imageUrl']),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x111D1617),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent],
                    ),
                  ),
                  padding: const EdgeInsets.all(10),
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.formatDate(photoData['createdAt']),
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                      ),
                      if (photoData['weightAtTime'] != null && photoData['weightAtTime'].toString().isNotEmpty)
                        Text(
                          '${photoData['weightAtTime']} kg',
                          style: const TextStyle(color: Color(0xFFC050F6), fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.addProgressPhoto,
        backgroundColor: const Color(0xFFC050F6),
        elevation: 4,
        child: const Icon(Icons.add_a_photo, color: Colors.white),
      ),
    );
  }
}
