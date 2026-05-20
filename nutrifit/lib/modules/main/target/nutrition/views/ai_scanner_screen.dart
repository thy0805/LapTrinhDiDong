import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nutrifit/modules/auth/controllers/auth_controller.dart';
import 'package:nutrifit/modules/main/target/nutrition/controllers/ai_scanner_controller.dart';
import 'package:nutrifit/modules/main/target/nutrition/controllers/nutrition_controller.dart';

class AiScannerScreen extends StatelessWidget {
  const AiScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AiScannerController());
    final auth = Get.find<AuthController>();
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Quét Món Ăn Bằng AI', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
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
            Obx(() => Container(
                  height: 280,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
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
                              auth.greeting,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Chụp hình để AI tính calo giúp ${auth.userPronoun} nhé!',
                              style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 14),
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
    final auth = Get.find<AuthController>();
    final food = controller.selectedFood.value;
    final isManual = controller.isManualEntry.value;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
              decoration: InputDecoration(
                hintText: 'Nhập tên món ăn...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade500 : Colors.grey),
              ),
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF2D3436)),
            )
          else
            Text(
              food!['name'],
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF2D3436)),
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
                  style: TextStyle(fontSize: 12, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade500),
                ),
            ],
          ),
          
          const Divider(height: 40),
          
          if (!isManual) ...[
            Text(
              'Ăn phần này cỡ nào?',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPortionChip(context, controller, 'Small', 'Nhỏ'),
                _buildPortionChip(context, controller, 'Medium', 'Vừa'),
                _buildPortionChip(context, controller, 'Large', 'Lớn'),
              ],
            ),
            const SizedBox(height: 24),
          ],
          
          Text(
            'Thời gian & Buổi ăn:',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Obx(() => DropdownButtonFormField<String>(
                  initialValue: controller.selectedMealType.value,
                  dropdownColor: Theme.of(context).colorScheme.surface,
                  style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: ['Bữa sáng', 'Bữa trưa', 'Bữa tối', 'Bữa nhẹ']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyle(fontSize: 13, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black))))
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
                      border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade700 : Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Obx(() => Text(
                      '${controller.selectedTime.value.hour}:${controller.selectedTime.value.minute.toString().padLeft(2, '0')}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                    )),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () {
              Get.defaultDialog(
                title: 'Sửa lượng Calo',
                titleStyle: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                backgroundColor: Theme.of(context).colorScheme.surface,
                content: TextField(
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Nhập số Calo...',
                    hintStyle: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade500 : Colors.grey),
                  ),
                  onChanged: (v) => controller.updateCalories(int.tryParse(v) ?? 0),
                ),
                textConfirm: 'Xong',
                confirmTextColor: Colors.white,
                buttonColor: Colors.orange,
                onConfirm: () => Get.back(),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.orange.withValues(alpha: 0.15) : Colors.orange.shade50,
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
            Text(
              'Có phải món này không?',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey),
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
                      label: Text(p['name'], style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)),
                      onPressed: () => controller.selectFood(p),
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      side: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade700 : Colors.grey, width: 0.5),
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
              
              String? finalImageUrl;
              if (controller.selectedImage.value != null) {
                Get.showOverlay(
                  asyncFunction: () async {
                    finalImageUrl = await controller.uploadImage();
                  },
                  loadingWidget: const Center(child: CircularProgressIndicator()),
                );
              }

              String name = isManual ? controller.manualFoodName.value : food!['name'];
              await nutritionController.addMealWithCalories(
                name,
                controller.selectedMealType.value,
                controller.calculatedCalories,
                imagePath: finalImageUrl ?? controller.selectedImage.value?.path,
                portionSize: controller.selectedPortion.value,
                customTime: controller.selectedTime.value,
              );

              Get.snackbar(
                'Thành công rực rỡ! 🎉',
                auth.successMessage(name),
                snackPosition: SnackPosition.TOP,
                backgroundColor: Colors.green.withValues(alpha: 0.9),
                colorText: Colors.white,
                borderRadius: 20,
                margin: const EdgeInsets.all(15),
                icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                duration: const Duration(seconds: 3),
              );

              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF2D3436),
              foregroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
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

  Widget _buildPortionChip(BuildContext context, AiScannerController controller, String value, String label) {
    return Obx(() {
      final isSelected = controller.selectedPortion.value == value;
      return GestureDetector(
        onTap: () => controller.updatePortion(value),
        child: Container(
          width: Get.width * 0.23,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? Colors.blue : (Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade700 : Colors.grey.shade300), width: 1.5),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : (Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade300 : Colors.grey.shade700),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      );
    });
  }
}

