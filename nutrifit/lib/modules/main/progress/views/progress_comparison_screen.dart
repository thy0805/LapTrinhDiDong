import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:screenshot/screenshot.dart';
import '../controllers/progress_controller.dart';

class ProgressComparisonScreen extends StatelessWidget {
  final ProgressController controller = Get.find();

  ProgressComparisonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('So Sánh Thành Quả', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins', fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.black), onPressed: () => Get.back()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Screenshot(
              controller: controller.screenshotController,
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildPhotoBox(context, isBefore: true)),
                        const SizedBox(width: 15),
                        Expanded(child: _buildPhotoBox(context, isBefore: false)),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Obx(() => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem('Thời gian', controller.timeDifferenceText, Colors.blue),
                          Container(height: 50, width: 1, color: Colors.grey[300]),
                          _buildStatItem('Kết quả', controller.weightDifferenceText, Colors.orange),
                        ],
                      )),
                    ),
                    const SizedBox(height: 10),
                    const Text('Made with NutriFit', style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic, fontFamily: 'Poppins')),
                  ],
                ),
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () async {
                  Get.dialog(const Center(child: CircularProgressIndicator(color: Color(0xFFC050F6))), barrierDismissible: false);
                  final image = await controller.screenshotController.capture();
                  Get.back(); 
                  controller.shareComparisonImage(image);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC050F6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                icon: const Icon(Icons.share, color: Colors.white),
                label: const Text('Chia Sẻ Lên Mạng Xã Hội', style: TextStyle(fontSize: 16, color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  // Widget: Khung chọn ảnh
  Widget _buildPhotoBox(BuildContext context, {required bool isBefore}) {
    return GestureDetector(
      onTap: () {
        if (controller.progressPhotos.isEmpty) {
           Get.snackbar('Trống', 'Bạn chưa chụp bức ảnh nào!');
           return;
        }

        Get.bottomSheet(
          Container(
            height: 400,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Text(isBefore ? 'Chọn ảnh Trước' : 'Chọn ảnh Sau', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                const SizedBox(height: 15),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10),
                    itemCount: controller.progressPhotos.length,
                    itemBuilder: (context, index) {
                      var photo = controller.progressPhotos[index];
                      return GestureDetector(
                        onTap: () {
                          controller.selectPhotoForComparison(photo, isBefore);
                          Get.back();
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(photo['imageUrl'], fit: BoxFit.cover),
                        ),
                      );
                    }
                  ),
                ),
              ],
            ),
          )
        );
      },
      child: Obx(() {
        var photoData = isBefore ? controller.beforePhoto.value : controller.afterPhoto.value;
        
        return Container(
          height: 250,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey[300]!, width: 2),
            image: photoData != null 
              ? DecorationImage(image: NetworkImage(photoData['imageUrl']), fit: BoxFit.cover) 
              : null,
          ),
          child: photoData == null 
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo, color: Colors.grey[400], size: 40),
                      const SizedBox(height: 10),
                      Text(isBefore ? 'Chọn ảnh TRƯỚC' : 'Chọn ảnh SAU', style: TextStyle(color: Colors.grey[500], fontFamily: 'Poppins', fontSize: 12)),
                    ],
                  ),
                ) 
              : const SizedBox.shrink(),
        );
      }),
    );
  }

  // Widget: Cột hiển thị thông số
  Widget _buildStatItem(String title, String value, Color color) {
    return Column(
      children: [
        Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 14, fontFamily: 'Poppins')),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color, fontFamily: 'Poppins'), textAlign: TextAlign.center,),
      ],
    );
  }
}
