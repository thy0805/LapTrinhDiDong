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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('So Sánh Thành Quả', style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontFamily: 'Poppins', fontSize: 16)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), onPressed: () => Get.back()),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            Screenshot(
              controller: controller.screenshotController,
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildPhotoBox(context, isBefore: true)),
                        SizedBox(width: 15),
                        Expanded(child: _buildPhotoBox(context, isBefore: false)),
                      ],
                    ),
                    SizedBox(height: 30),
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark ? Color(0xFF1E293B) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Obx(() => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(context, 'Thời gian', controller.timeDifferenceText, Colors.blue),
                          Container(height: 50, width: 1, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[300]),
                          _buildStatItem(context, 'Kết quả', controller.weightDifferenceText, Colors.orange),
                        ],
                      )),
                    ),
                    SizedBox(height: 10),
                    Text('Made with NutriFit', style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic, fontFamily: 'Poppins')),
                  ],
                ),
              ),
            ),

            Obx(() => controller.beforePhoto.value != null && controller.afterPhoto.value != null
                ? Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final isDark = Theme.of(context).brightness == Brightness.dark;
                          final surfaceColor = Theme.of(context).colorScheme.surface;
                          Get.dialog(
                            Center(child: CircularProgressIndicator(color: Get.theme.colorScheme.primary)),
                            barrierDismissible: false,
                          );
                          try {
                            final result = await controller.analyzeComparison();
                            Get.back();
                            Get.bottomSheet(
                              Container(
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: surfaceColor,
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                ),
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.auto_awesome, color: Colors.amber),
                                          SizedBox(width: 10),
                                          Text('AI Nhận Xét Tiến Độ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins', color: isDark ? Colors.white : Colors.black)),
                                        ],
                                      ),
                                      SizedBox(height: 15),
                                      Text(
                                        result,
                                        style: TextStyle(fontSize: 14, height: 1.5, fontFamily: 'Poppins', color: isDark ? Colors.white70 : Colors.black87),
                                      ),
                                      SizedBox(height: 20),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: () => Get.back(),
                                          child: Text('Đóng'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          } catch (e) {
                            Get.back();
                            Get.snackbar('Lỗi', e.toString().replaceAll('Exception: ', ''), backgroundColor: Colors.redAccent, colorText: Colors.white);
                          }
                        },
                        icon: Icon(Icons.auto_awesome, color: Colors.amber),
                        label: Text('Nhờ AI Đánh Giá Sự Thay Đổi', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.white,
                          foregroundColor: Get.theme.colorScheme.primary,
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                      ),
                    ),
                  )
                : SizedBox.shrink()),

            Spacer(),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () async {
                  Get.dialog(Center(child: CircularProgressIndicator(color: Get.theme.colorScheme.primary)), barrierDismissible: false);
                  final image = await controller.screenshotController.capture();
                  Get.back(); 
                  controller.shareComparisonImage(image);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Get.theme.colorScheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                icon: Icon(Icons.share, color: Colors.white),
                label: Text('Chia Sẻ Lên Mạng Xã Hội', style: TextStyle(fontSize: 16, color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
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
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Text(isBefore ? 'Chọn ảnh Trước' : 'Chọn ảnh Sau', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins', color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)),
                SizedBox(height: 15),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10),
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
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(photo['imageUrl'], fit: BoxFit.cover),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  width: double.infinity,
                                  color: Colors.black.withValues(alpha: 0.6),
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Text(
                                    controller.formatDate(photo['createdAt']),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
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
            color: Theme.of(context).brightness == Brightness.dark ? Color(0xFF1E293B) : Colors.grey[200],
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800]! : Colors.grey[300]!, width: 2),
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
                      SizedBox(height: 10),
                      Text(isBefore ? 'Chọn ảnh TRƯỚC' : 'Chọn ảnh SAU', style: TextStyle(color: Colors.grey[500], fontFamily: 'Poppins', fontSize: 12)),
                    ],
                  ),
                ) 
              : Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(13)),
                    ),
                    child: Text(
                      controller.formatDate(photoData['createdAt']),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
        );
      }),
    );
  }

  Widget _buildStatItem(BuildContext context, String title, String value, Color color) {
    return Column(
      children: [
        Text(title, style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[600], fontSize: 14, fontFamily: 'Poppins')),
        SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color, fontFamily: 'Poppins'), textAlign: TextAlign.center,),
      ],
    );
  }
}
