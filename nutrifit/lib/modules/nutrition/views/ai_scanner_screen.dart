import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nutrifit/core/utils/dynamic_text_helper.dart';
import 'package:nutrifit/modules/nutrition/controllers/ai_scanner_controller.dart';
import 'package:nutrifit/modules/nutrition/controllers/nutrition_controller.dart';

class AiScannerScreen extends StatelessWidget {
  const AiScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AiScannerController());
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Quét Món Ăn Bằng AI', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.reset,
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Khu vực hiển thị ảnh
            Obx(() => Container(
                  height: 280,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: controller.selectedImage.value != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Image.file(
                            controller.selectedImage.value!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.add_a_photo_rounded, size: 50, color: Colors.blue),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              DynamicTextHelper.getGreeting(),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Chụp hình để AI tính calo giúp ${DynamicTextHelper.getPronoun()} nhé!',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                            ),
                          ],
                        ),
                )),
            const SizedBox(height: 24),

            // Nút chọn ảnh
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    label: 'Chụp ảnh',
                    icon: Icons.camera_alt_rounded,
                    color: Colors.blue,
                    onPressed: () => controller.pickImage(ImageSource.camera),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionButton(
                    label: 'Thư viện',
                    icon: Icons.photo_library_rounded,
                    color: Colors.orange,
                    onPressed: () => controller.pickImage(ImageSource.gallery),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Khu vực kết quả
            Obx(() {
              if (controller.isScanning.value) {
                return _buildLoadingState();
              }

              if (controller.selectedFood.value != null || controller.isManualEntry.value) {
                return _buildResultCard(controller, context);
              }

              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({required String label, required IconData icon, required Color color, required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        const CircularProgressIndicator(strokeWidth: 3),
        const SizedBox(height: 20),
        const Text(
          'AI đang soi món ăn... Đợi xíu nhen!',
          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.blue),
        ),
        const SizedBox(height: 20),
        TextButton.icon(
          onPressed: () => Get.find<AiScannerController>().setManualEntry(),
          icon: const Icon(Icons.edit_note, color: Colors.grey),
          label: const Text('Nhập tay luôn cho lẹ', style: TextStyle(color: Colors.grey)),
        ),
      ],
    );
  }

  Widget _buildResultCard(AiScannerController controller, BuildContext context) {
    final food = controller.selectedFood.value;
    final isManual = controller.isManualEntry.value;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              const Text(
                'AI NHẬN DIỆN LÀ:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.blue, letterSpacing: 1.2),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (isManual)
            TextField(
              onChanged: (v) => controller.manualFoodName.value = v,
              decoration: const InputDecoration(
                hintText: 'Nhập tên món ăn...',
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2D3436)),
            )
          else
            Text(
              food!['name'],
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Color(0xFF2D3436)),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isManual ? 'Tự nhập' : (food!['category'] ?? 'Món ăn'),
                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              const SizedBox(width: 12),
              if (!isManual)
                Text(
                  'Độ chính xác: ${(food!['confidence'] * 100).toStringAsFixed(1)}%',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
            ],
          ),
          
          const Divider(height: 40),
          
          if (!isManual) ...[
            const Text(
              'Ăn phần này cỡ nào?',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPortionChip(controller, 'Small', 'Nhỏ'),
                _buildPortionChip(controller, 'Medium', 'Vừa'),
                _buildPortionChip(controller, 'Large', 'Lớn'),
              ],
            ),
            const SizedBox(height: 24),
          ],
          
          const Text(
            'Thời gian & Buổi ăn:',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Obx(() => DropdownButtonFormField<String>(
                  initialValue: controller.selectedMealType.value,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: ['Bữa sáng', 'Bữa trưa', 'Bữa tối', 'Bữa nhẹ']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13))))
                      .toList(),
                  onChanged: (v) => controller.updateMealType(v!),
                )),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                    if (picked != null) {
                      final now = DateTime.now();
                      controller.updateTime(DateTime(now.year, now.month, now.day, picked.hour, picked.minute));
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Obx(() => Text(
                      '${controller.selectedTime.value.hour}:${controller.selectedTime.value.minute.toString().padLeft(2, '0')}',
                      textAlign: TextAlign.center,
                    )),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () {
              // Dialog sửa calo cho Thy nhen
              Get.defaultDialog(
                title: 'Sửa lượng Calo',
                content: TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'Nhập số Calo...'),
                  onChanged: (v) => controller.updateCalories(int.tryParse(v) ?? 0),
                ),
                textConfirm: 'Xong',
                onConfirm: () => Get.back(),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('TỔNG CALO (Bấm để sửa)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange)),
                      const SizedBox(height: 4),
                      Obx(() => Text(
                        '${controller.calculatedCalories} kcal',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.orange),
                      )),
                    ],
                  ),
                  const Icon(Icons.local_fire_department_rounded, size: 40, color: Colors.orange),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          if (!isManual && controller.predictions.length > 1) ...[
            const Text(
              'Có phải món này không?',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.predictions.length,
                itemBuilder: (context, index) {
                  final p = controller.predictions[index];
                  if (p['id'] == food!['id']) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: ActionChip(
                      label: Text(p['name']),
                      onPressed: () => controller.selectFood(p),
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Colors.grey, width: 0.5),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
          
          if (!isManual)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextButton.icon(
                onPressed: () => controller.setManualEntry(),
                icon: const Icon(Icons.edit_note, size: 18),
                label: const Text('Đoán sai rồi, tui muốn tự nhập', style: TextStyle(fontSize: 12)),
              ),
            ),
          
          Obx(() => ElevatedButton(
            onPressed: controller.isUploading.value ? null : () async {
              final nutritionController = Get.find<NutritionController>();
              
              // 1. Upload ảnh lên Firebase Storage cho chắc ăn nhen Thy
              String? finalImageUrl;
              if (controller.selectedImage.value != null) {
                Get.showOverlay(
                  asyncFunction: () async {
                    finalImageUrl = await controller.uploadImage();
                  },
                  loadingWidget: const Center(child: CircularProgressIndicator()),
                );
              }

              // 2. Thêm món vào nhật ký
              String name = isManual ? controller.manualFoodName.value : food!['name'];
              await nutritionController.addMealWithCalories(
                name,
                controller.selectedMealType.value,
                controller.calculatedCalories,
                imagePath: finalImageUrl ?? controller.selectedImage.value?.path,
                portionSize: controller.selectedPortion.value,
                customTime: controller.selectedTime.value,
              );

              // Thông báo xịn xò nè
              Get.snackbar(
                'Thành công rực rỡ! 🎉',
                DynamicTextHelper.getSuccessMessage(name),
                snackPosition: SnackPosition.TOP,
                backgroundColor: Colors.green.withValues(alpha: 0.9),
                colorText: Colors.white,
                borderRadius: 20,
                margin: const EdgeInsets.all(15),
                icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                duration: const Duration(seconds: 3),
              );

              // Quay về màn hình trước
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D3436),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 5,
              shadowColor: Colors.black.withValues(alpha: 0.3),
            ),
            child: controller.isUploading.value 
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('XÁC NHẬN ĂN MÓN NÀY', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
          ))
        ],
      ),
    );
  }

  Widget _buildPortionChip(AiScannerController controller, String value, String label) {
    return Obx(() {
      final isSelected = controller.selectedPortion.value == value;
      return GestureDetector(
        onTap: () => controller.updatePortion(value),
        child: Container(
          width: Get.width * 0.23,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? Colors.blue : Colors.grey.shade300, width: 1.5),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade700,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      );
    });
  }
}

