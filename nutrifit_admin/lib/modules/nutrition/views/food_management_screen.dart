import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutrifit_admin/core/theme/tailadmin_design_system.dart';
import 'package:nutrifit_admin/core/widgets/app_table.dart';
import 'package:nutrifit_admin/core/services/file_service.dart';
import 'package:nutrifit_admin/modules/nutrition/controllers/food_management_controller.dart';
import 'package:nutrifit_admin/core/models/food_item.dart';

class FoodManagementScreen extends StatelessWidget {
  const FoodManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FoodManagementController>();
    final RxInt selectedTab = 0.obs;

    return Obx(() {
      TailAdminDesign.isDark;

      return DefaultTabController(
        length: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quản lý Dinh dưỡng',
                      style: GoogleFonts.outfit(
                        fontSize: TailAdminDesign.font2xl,
                        fontWeight: FontWeight.bold,
                        color: TailAdminDesign.textMain,
                      ),
                    ),
                    Text(
                      'Quản lý danh sách thực phẩm, chỉ số Calo/Macro và duyệt món ăn từ người dùng.',
                      style: GoogleFonts.outfit(
                        fontSize: TailAdminDesign.fontSm,
                        color: TailAdminDesign.textMuted,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showFoodDialog(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: Text('Thêm món ăn', style: GoogleFonts.outfit(fontWeight: FontWeight.w500)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TailAdminDesign.brand500,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(TailAdminDesign.radiusMd)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: TailAdminDesign.sp8),
            // Custom Tabs
            Obx(() => Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: TailAdminDesign.bgCard,
                borderRadius: BorderRadius.circular(TailAdminDesign.radiusMd),
                border: Border.all(color: TailAdminDesign.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTabButton('Danh sách thực phẩm', 0, selectedTab),
                  const SizedBox(width: 4),
                  _buildTabButton('Chờ duyệt món', 1, selectedTab),
                ],
              ),
            )),
            const SizedBox(height: TailAdminDesign.sp6),
            // Content
            Obx(() => _buildFoodListTab(context, controller, isPending: selectedTab.value == 1)),
          ],
        ),
      );
    });
  }

  Widget _buildFoodListTab(BuildContext context, FoodManagementController controller, {required bool isPending}) {
    return Column(
      children: [
        if (!isPending) ...[
          Container(
            padding: const EdgeInsets.all(TailAdminDesign.sp4),
            decoration: BoxDecoration(
              color: TailAdminDesign.bgCard,
              borderRadius: BorderRadius.circular(TailAdminDesign.radiusLg),
              border: Border.all(color: TailAdminDesign.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: controller.setSearchText,
                    style: GoogleFonts.outfit(color: TailAdminDesign.textMain, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm món ăn...',
                      hintStyle: GoogleFonts.outfit(color: TailAdminDesign.textMuted, fontSize: 14),
                      prefixIcon: Icon(Icons.search, color: TailAdminDesign.textMuted, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(TailAdminDesign.radiusMd),
                        borderSide: BorderSide(color: TailAdminDesign.border),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Obx(() => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: TailAdminDesign.border),
                    borderRadius: BorderRadius.circular(TailAdminDesign.radiusMd),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: controller.selectedCategory.value,
                      dropdownColor: TailAdminDesign.bgCard,
                      style: GoogleFonts.outfit(color: TailAdminDesign.textMain, fontSize: 14),
                      items: ['Tất cả', 'Món nước', 'Món khô', 'Ăn sáng', 'Ăn sáng/trưa', 'Quà vặt', 'Ăn nhẹ', 'Cơm gia đình', 'Đồ ngọt', 'Món truyền thống'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (val) => controller.setCategory(val!),
                    ),
                  ),
                )),
              ],
            ),
          ),
          const SizedBox(height: TailAdminDesign.sp6),
        ],
        Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: Padding(
              padding: EdgeInsets.all(40.0),
              child: CircularProgressIndicator(),
            ));
          }
          final foods = isPending ? controller.pendingFoods : controller.filteredFoods.where((f) => f.status == 'approved').toList();
          
          return AppTable<FoodItem>(
            title: isPending ? 'Danh sách chờ duyệt' : 'Danh mục thực đơn',
            columns: const ['ẢNH', 'TÊN MÓN ĂN', 'CALORIES', 'MACROS (P/C/F)', 'DANH MỤC', 'THAO TÁC'],
            data: foods,
            cellBuilder: (food) => [
              DataCell(
                SizedBox(
                  width: 50,
                  height: 40,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(TailAdminDesign.radiusSm),
                    child: food.image.isNotEmpty ? Image.network(
                      food.image,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: TailAdminDesign.hover,
                          child: Center(
                            child: Icon(Icons.image_outlined, color: TailAdminDesign.textMuted.withValues(alpha: 0.3), size: 20),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: TailAdminDesign.hover,
                        child: Icon(Icons.fastfood, size: 18, color: TailAdminDesign.textMuted),
                      ),
                    ) : Container(
                        color: TailAdminDesign.hover,
                        child: Icon(Icons.fastfood, size: 18, color: TailAdminDesign.textMuted),
                      ),
                  ),
                ),
              ),
              DataCell(Text(food.title, style: GoogleFonts.outfit(color: TailAdminDesign.textMain, fontWeight: FontWeight.w500))),
              DataCell(Text('${food.calories} kcal', style: GoogleFonts.outfit(color: TailAdminDesign.textMuted))),
              DataCell(Text('${food.protein}g / ${food.carbs}g / ${food.fat}g', style: GoogleFonts.outfit(color: TailAdminDesign.textMuted, fontSize: 13))),
              DataCell(Text(food.category, style: GoogleFonts.outfit(color: TailAdminDesign.textMuted))),
              DataCell(
                Row(
                  children: [
                    if (isPending)
                      IconButton(
                        onPressed: () => controller.approveFood(food.id), 
                        icon: const Icon(Icons.check_circle_outline_rounded, size: 20), 
                        color: TailAdminDesign.success
                      ),
                    IconButton(
                      onPressed: () => _showFoodDialog(context, food: food), 
                      icon: const Icon(Icons.edit_outlined, size: 20), 
                      color: TailAdminDesign.brand600
                    ),
                    IconButton(
                      onPressed: () => controller.deleteFood(food.id),
                      icon: const Icon(Icons.delete_outline_rounded, size: 20),
                      color: TailAdminDesign.danger,
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  void _showFoodDialog(BuildContext context, {FoodItem? food}) {
    final controller = Get.find<FoodManagementController>();
    final titleController = TextEditingController(text: food?.title ?? '');
    final caloriesController = TextEditingController(text: food?.calories ?? '');
    final proteinController = TextEditingController(text: food?.protein ?? '0');
    final carbsController = TextEditingController(text: food?.carbs ?? '0');
    final fatController = TextEditingController(text: food?.fat ?? '0');
    final imageController = TextEditingController(text: food?.image ?? '');
    String selectedCat = food?.category ?? 'Món nước';

    Get.dialog(
      Dialog(
        backgroundColor: TailAdminDesign.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(TailAdminDesign.radiusLg)),
        child: Container(
          width: 550,
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food == null ? 'Thêm món ăn mới' : 'Chỉnh sửa món ăn',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: TailAdminDesign.textMain,
                  ),
                ),
                const SizedBox(height: 20),
                _buildField('Tên món ăn', titleController),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildField('Calories (kcal)', caloriesController)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildField('Protein (g)', proteinController)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildField('Carbs (g)', carbsController)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildField('Fat (g)', fatController)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(child: _buildField('Link hình ảnh (URL)', imageController)),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () async {
                        // Truyền food.id vào để Cloudinary biết đường mà ghi đè ảnh cũ nhen Thy
                        final url = await Get.find<FileService>().pickAndUploadImage('foods', fileName: food?.id);
                        if (url != null) {
                          imageController.text = url;
                          Get.snackbar('Thành công', 'Đã tải lên hình ảnh mới cho ${food?.title ?? "món ăn"}');
                        }
                      },
                      icon: const Icon(Icons.add_photo_alternate_rounded, size: 18),
                      label: const Text('Tải lên'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TailAdminDesign.brand500,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(TailAdminDesign.radiusMd)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Danh mục', style: GoogleFonts.outfit(fontSize: 14, color: TailAdminDesign.textMuted)),
                const SizedBox(height: 8),
                StatefulBuilder(
                  builder: (context, setState) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: TailAdminDesign.border),
                      borderRadius: BorderRadius.circular(TailAdminDesign.radiusMd),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedCat,
                        dropdownColor: TailAdminDesign.bgCard,
                        style: GoogleFonts.outfit(color: TailAdminDesign.textMain, fontSize: 14),
                        items: ['Món nước', 'Món khô', 'Ăn sáng', 'Ăn sáng/trưa', 'Quà vặt', 'Ăn nhẹ', 'Cơm gia đình', 'Đồ ngọt', 'Món truyền thống'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() => selectedCat = val!);
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text('Hủy', style: GoogleFonts.outfit(color: TailAdminDesign.textMuted)),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        final newFood = FoodItem(
                          id: food?.id ?? '',
                          title: titleController.text,
                          calories: caloriesController.text,
                          category: selectedCat,
                          image: imageController.text,
                          protein: proteinController.text,
                          carbs: carbsController.text,
                          fat: fatController.text,
                          status: food?.status ?? 'approved',
                        );
                        if (food == null) {
                          controller.addFood(newFood);
                        } else {
                          controller.updateFood(food.id, newFood);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TailAdminDesign.brand500,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(TailAdminDesign.radiusMd)),
                      ),
                      child: Text(food == null ? 'Thêm ngay' : 'Cập nhật'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.outfit(fontSize: 14, color: TailAdminDesign.textMuted)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: GoogleFonts.outfit(color: TailAdminDesign.textMain, fontSize: 14),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(TailAdminDesign.radiusMd),
              borderSide: BorderSide(color: TailAdminDesign.border),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildTabButton(String title, int index, RxInt selectedTab) {
    bool isActive = selectedTab.value == index;
    return InkWell(
      onTap: () => selectedTab.value = index,
      borderRadius: BorderRadius.circular(TailAdminDesign.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? TailAdminDesign.brand500.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(TailAdminDesign.radiusMd),
          border: Border.all(color: isActive ? TailAdminDesign.brand500 : Colors.transparent),
        ),
        child: Text(
          title,
          style: GoogleFonts.outfit(
            color: isActive ? TailAdminDesign.brand500 : TailAdminDesign.textMuted,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
