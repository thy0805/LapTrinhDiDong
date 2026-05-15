import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutrifit_admin/core/theme/tailadmin_design_system.dart';
import 'package:nutrifit_admin/core/widgets/app_table.dart';
import 'package:nutrifit_admin/core/services/file_service.dart';
import 'package:nutrifit_admin/modules/workout/controllers/workout_management_controller.dart';
import 'package:nutrifit_admin/core/models/workout_model.dart';

class WorkoutManagementScreen extends StatelessWidget {
  const WorkoutManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WorkoutManagementController>();

    return Obx(() {
      TailAdminDesign.isDark;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.translate('title'),
                  style: GoogleFonts.outfit(
                    fontSize: TailAdminDesign.font2xl,
                    fontWeight: FontWeight.bold,
                    color: TailAdminDesign.textMain,
                  ),
                ),
                Text(
                  controller.translate('subtitle'),
                  style: GoogleFonts.outfit(
                    fontSize: TailAdminDesign.fontSm,
                    color: TailAdminDesign.textMuted,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: TailAdminDesign.bgMain,
                    borderRadius: BorderRadius.circular(TailAdminDesign.radiusMd),
                    border: Border.all(color: TailAdminDesign.border),
                  ),
                  child: Row(
                    children: [
                      _buildLangButton(controller, 'en', 'EN'),
                      _buildLangButton(controller, 'vi', 'VI'),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => _showExerciseDialog(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(controller.translate('add_btn'), style: GoogleFonts.outfit(fontWeight: FontWeight.w500)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TailAdminDesign.brand500,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(TailAdminDesign.radiusMd)),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: TailAdminDesign.sp8),
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
                    hintText: controller.translate('search_hint'),
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
                    items: controller.availableCategories.map((String value) {
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
        Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: Padding(
              padding: EdgeInsets.all(40.0),
              child: CircularProgressIndicator(),
            ));
          }
          return AppTable<ExerciseItem>(
            title: controller.translate('table_title'),
            columns: [
              controller.translate('col_img'),
              controller.translate('col_name'),
              controller.translate('col_diff'),
              controller.translate('col_cal'),
              controller.translate('col_cat'),
              controller.translate('col_act'),
            ],
            data: controller.paginatedExercises,
            currentPage: controller.currentPage.value,
            totalPages: controller.totalPages,
            onPageChanged: (page) => controller.currentPage.value = page,
            cellBuilder: (ex) {
              Color difficultyColor;
              String diffLower = ex.difficulty.toLowerCase();
              if (diffLower.contains('dễ') || diffLower.contains('easy')) {
                difficultyColor = const Color(0xFF10B981);
              } else if (diffLower.contains('trung bình') || diffLower.contains('normal')) {
                difficultyColor = const Color(0xFFF59E0B);
              } else if (diffLower.contains('khó') || diffLower.contains('hard')) {
                difficultyColor = const Color(0xFFEF4444);
              } else {
                difficultyColor = const Color(0xFF3BA2B8);
              }

              return [
                DataCell(
                  UnconstrainedBox(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: 60,
                      height: 60,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(TailAdminDesign.radiusSm),
                      child: (ex.image.isNotEmpty && (ex.image.startsWith('http') || ex.image.contains('/'))) ? Image.network(
                          ex.image,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: TailAdminDesign.hover,
                              child: Center(
                                child: Icon(Icons.fitness_center_rounded, color: TailAdminDesign.textMuted.withValues(alpha: 0.2), size: 24),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: TailAdminDesign.hover,
                            child: Icon(Icons.fitness_center_rounded, size: 24, color: TailAdminDesign.textMuted),
                          ),
                        ) : Container(
                          color: TailAdminDesign.hover,
                          child: Icon(Icons.fitness_center_rounded, size: 24, color: TailAdminDesign.textMuted),
                        ),
                      ),
                    ),
                  ),
                ),
                DataCell(Text(ex.title, style: GoogleFonts.outfit(color: TailAdminDesign.textMain, fontWeight: FontWeight.w500, fontSize: 13))),
                DataCell(
                  UnconstrainedBox(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: difficultyColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(TailAdminDesign.radiusSm),
                      ),
                      child: Text(
                        ex.difficulty,
                        style: GoogleFonts.outfit(
                          color: difficultyColor,
                          fontSize: TailAdminDesign.fontXs,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                DataCell(Text('${ex.calories} kcal', style: GoogleFonts.outfit(color: TailAdminDesign.textMuted, fontSize: 13))),
                DataCell(Text(ex.category, style: GoogleFonts.outfit(color: TailAdminDesign.textMuted, fontSize: 13))),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => _showExerciseDialog(context, ex: ex), 
                        icon: const Icon(Icons.edit_outlined, size: 18), 
                        color: TailAdminDesign.brand600
                      ),
                      IconButton(
                        onPressed: () => controller.deleteExercise(ex.id),
                        icon: const Icon(Icons.delete_outline_rounded, size: 18),
                        color: TailAdminDesign.danger,
                      ),
                    ],
                  ),
                ),
              ];
            },
          );
        }),
      ],
    );
    });
  }

  void _showExerciseDialog(BuildContext context, {ExerciseItem? ex}) {
    final controller = Get.find<WorkoutManagementController>();
    final titleController = TextEditingController(text: ex?.title ?? '');
    final caloriesController = TextEditingController(text: ex?.calories.toString() ?? '');
    final descController = TextEditingController(text: ex?.description ?? '');
    final imageController = TextEditingController(text: ex?.image ?? '');
    
    String allLabel = controller.currentLanguage.value == 'vi' ? 'Tất cả' : 'All';
    List<String> dialogCats = controller.availableCategories.where((c) => c != allLabel).toList();
    if (dialogCats.isEmpty) {
      dialogCats.add(controller.currentLanguage.value == 'vi' ? 'Khác' : 'Other');
    }
    
    String selectedCat = ex?.category ?? dialogCats.first;
    if (!dialogCats.contains(selectedCat)) {
      selectedCat = dialogCats.first;
    }
    
    final diffLevels = controller.currentLanguage.value == 'vi' 
        ? ['Dễ', 'Trung bình', 'Khó'] 
        : ['Easy', 'Normal', 'Hard'];

    String selectedDiff = ex?.difficulty ?? diffLevels.first;
    
    if (!diffLevels.contains(selectedDiff)) {
      if (selectedDiff.toLowerCase().contains('dễ') || selectedDiff.toLowerCase().contains('easy')) {
        selectedDiff = diffLevels[0];
      } else if (selectedDiff.toLowerCase().contains('trung bình') || selectedDiff.toLowerCase().contains('normal')) {
        selectedDiff = diffLevels[1];
      } else if (selectedDiff.toLowerCase().contains('khó') || selectedDiff.toLowerCase().contains('hard')) {
        selectedDiff = diffLevels[2];
      } else {
        selectedDiff = diffLevels.first;
      }
    }

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
                  ex == null ? (controller.currentLanguage.value == 'vi' ? 'Thêm bài tập mới' : 'Add New Exercise') : (controller.currentLanguage.value == 'vi' ? 'Chỉnh sửa bài tập' : 'Edit Exercise'),
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: TailAdminDesign.textMain,
                  ),
                ),
                const SizedBox(height: 20),
                _buildField(controller.currentLanguage.value == 'vi' ? 'Tên bài tập' : 'Exercise Name', titleController),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildField(controller.currentLanguage.value == 'vi' ? 'Calo tiêu hao / phút' : 'Calories / min', caloriesController)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(controller.currentLanguage.value == 'vi' ? 'Độ khó' : 'Difficulty', style: GoogleFonts.outfit(fontSize: 14, color: TailAdminDesign.textMuted)),
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
                                  value: selectedDiff,
                                  dropdownColor: TailAdminDesign.bgCard,
                                  style: GoogleFonts.outfit(color: TailAdminDesign.textMain, fontSize: 14),
                                  items: diffLevels.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (val) => setState(() => selectedDiff = val!),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildField(controller.currentLanguage.value == 'vi' ? 'Mô tả bài tập' : 'Description', descController, maxLines: 3),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(child: _buildField(controller.currentLanguage.value == 'vi' ? 'Link hình ảnh/video (URL)' : 'Image/Video URL', imageController)),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final url = await Get.find<FileService>().pickAndUploadGif('workouts');
                        if (url != null) {
                          imageController.text = url;
                          Get.snackbar('Thành công', 'Đã tải lên GIF/Video');
                        }
                      },
                      icon: const Icon(Icons.upload_file_rounded, size: 18),
                      label: Text(controller.currentLanguage.value == 'vi' ? 'Tải lên' : 'Upload'),
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
                Text(controller.currentLanguage.value == 'vi' ? 'Danh mục' : 'Category', style: GoogleFonts.outfit(fontSize: 14, color: TailAdminDesign.textMuted)),
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
                        items: dialogCats.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => selectedCat = val);
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
                      child: Text(controller.currentLanguage.value == 'vi' ? 'Hủy' : 'Cancel', style: GoogleFonts.outfit(color: TailAdminDesign.textMuted)),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        final newEx = ExerciseItem(
                          id: ex?.id ?? '',
                          title: titleController.text,
                          difficulty: selectedDiff,
                          calories: int.tryParse(caloriesController.text) ?? 0,
                          description: descController.text,
                          category: selectedCat,
                          image: imageController.text,
                        );
                        if (ex == null) {
                          controller.addExercise(newEx);
                        } else {
                          controller.updateExercise(ex.id, newEx);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TailAdminDesign.brand500,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(TailAdminDesign.radiusMd)),
                      ),
                      child: Text(ex == null ? (controller.currentLanguage.value == 'vi' ? 'Thêm ngay' : 'Add Now') : (controller.currentLanguage.value == 'vi' ? 'Cập nhật' : 'Update')),
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

  Widget _buildLangButton(WorkoutManagementController controller, String lang, String label) {
    bool isSelected = controller.currentLanguage.value == lang;
    return GestureDetector(
      onTap: () => controller.changeLanguage(lang),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? TailAdminDesign.brand500 : Colors.transparent,
          borderRadius: BorderRadius.circular(TailAdminDesign.radiusSm),
          boxShadow: isSelected ? [
            BoxShadow(
              color: TailAdminDesign.brand500.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ] : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : TailAdminDesign.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.outfit(fontSize: 14, color: TailAdminDesign.textMuted)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
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
}
