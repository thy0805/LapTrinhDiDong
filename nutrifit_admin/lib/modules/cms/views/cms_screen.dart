import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutrifit_admin/core/theme/tailadmin_design_system.dart';
import 'package:nutrifit_admin/core/widgets/app_table.dart';
import 'package:nutrifit_admin/core/services/file_service.dart';
import 'package:nutrifit_admin/modules/cms/controllers/cms_controller.dart';
import 'package:nutrifit_admin/core/models/article_model.dart';
import 'package:intl/intl.dart';

class CMSScreen extends StatelessWidget {
  const CMSScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CMSController());

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
                    'Quản trị Nội dung (CMS)',
                    style: GoogleFonts.outfit(
                      fontSize: TailAdminDesign.font2xl,
                      fontWeight: FontWeight.bold,
                      color: TailAdminDesign.textMain,
                    ),
                  ),
                  Text(
                    'Soạn thảo bài viết, mẹo vặt sức khỏe và tin tức cho người dùng.',
                    style: GoogleFonts.outfit(
                      fontSize: TailAdminDesign.fontSm,
                      color: TailAdminDesign.textMuted,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showArticleDialog(context),
                icon: const Icon(Icons.post_add_rounded, size: 18),
                label: Text('Viết bài mới', style: GoogleFonts.outfit(fontWeight: FontWeight.w500)),
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
          Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: Padding(
                padding: EdgeInsets.all(40.0),
                child: CircularProgressIndicator(),
              ));
            }
            return AppTable<ArticleItem>(
              title: 'Danh sách bài viết',
              columns: const ['ẢNH', 'TIÊU ĐỀ', 'DANH MỤC', 'NGÀY ĐĂNG', 'THAO TÁC'],
              data: controller.allArticles.toList(),
              cellBuilder: (article) => [
                DataCell(
                  SizedBox(
                    width: 60,
                    height: 40,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(TailAdminDesign.radiusSm),
                      child: article.image.isNotEmpty ? Image.network(
                        article.image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: TailAdminDesign.hover,
                          child: Icon(Icons.article_rounded, size: 18, color: TailAdminDesign.textMuted),
                        ),
                      ) : Container(
                          color: TailAdminDesign.hover,
                          child: Icon(Icons.article_rounded, size: 18, color: TailAdminDesign.textMuted),
                        ),
                    ),
                  ),
                ),
                DataCell(Text(article.title, style: GoogleFonts.outfit(color: TailAdminDesign.textMain, fontWeight: FontWeight.w500))),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: TailAdminDesign.brand500.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(TailAdminDesign.radiusSm),
                    ),
                    child: Text(
                      article.category,
                      style: GoogleFonts.outfit(color: TailAdminDesign.brand500, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                DataCell(Text(DateFormat('dd/MM/yyyy').format(article.createdAt), style: GoogleFonts.outfit(color: TailAdminDesign.textMuted))),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => _showArticleDialog(context, article: article), 
                        icon: const Icon(Icons.edit_outlined, size: 20), 
                        color: TailAdminDesign.brand600
                      ),
                      IconButton(
                        onPressed: () => controller.deleteArticle(article.id),
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
    });
  }

  void _showArticleDialog(BuildContext context, {ArticleItem? article}) {
    final controller = Get.find<CMSController>();
    final titleController = TextEditingController(text: article?.title ?? '');
    final contentController = TextEditingController(text: article?.content ?? '');
    final imageController = TextEditingController(text: article?.image ?? '');
    String selectedCat = article?.category ?? 'Mẹo vặt';

    Get.dialog(
      Dialog(
        backgroundColor: TailAdminDesign.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(TailAdminDesign.radiusLg)),
        child: Container(
          width: 800,
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article == null ? 'Soạn thảo bài viết mới' : 'Chỉnh sửa bài viết',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: TailAdminDesign.textMain,
                  ),
                ),
                const SizedBox(height: 20),
                _buildField('Tiêu đề bài viết', titleController),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                  items: ['Mẹo vặt', 'Tin tức', 'Dinh dưỡng', 'Tập luyện'].map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (val) => setState(() => selectedCat = val!),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatefulBuilder(
                        builder: (context, setStateDialog) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Ảnh đại diện', style: GoogleFonts.outfit(fontSize: 14, color: TailAdminDesign.textMuted)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: imageController,
                                    style: GoogleFonts.outfit(color: TailAdminDesign.textMain, fontSize: 14),
                                    onChanged: (val) => setStateDialog(() {}),
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(TailAdminDesign.radiusMd),
                                        borderSide: BorderSide(color: TailAdminDesign.border),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () async {
                                    final url = await Get.find<FileService>().pickAndUploadImage('articles');
                                    if (url != null) {
                                      setStateDialog(() {
                                        imageController.text = url;
                                      });
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: TailAdminDesign.brand500,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(TailAdminDesign.radiusMd)),
                                  ),
                                  child: const Icon(Icons.upload_rounded, size: 20),
                                ),
                              ],
                            ),
                            if (imageController.text.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(TailAdminDesign.radiusSm),
                                child: Image.network(
                                  imageController.text,
                                  height: 80,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    height: 80,
                                    color: TailAdminDesign.hover,
                                    child: Center(
                                      child: Icon(Icons.broken_image_outlined, color: TailAdminDesign.textMuted),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildField('Nội dung bài viết', contentController, maxLines: 15),
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
                        final newArticle = ArticleItem(
                          id: article?.id ?? '',
                          title: titleController.text,
                          content: contentController.text,
                          image: imageController.text,
                          category: selectedCat,
                          createdAt: article?.createdAt ?? DateTime.now(),
                        );
                        if (article == null) {
                          controller.addArticle(newArticle);
                        } else {
                          controller.updateArticle(article.id, newArticle);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TailAdminDesign.brand500,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(TailAdminDesign.radiusMd)),
                      ),
                      child: Text(article == null ? 'Đăng bài viết' : 'Cập nhật bài viết'),
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

  Widget _buildField(String label, TextEditingController controller, {int maxLines = 1, bool showLabel = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel) ...[
          Text(label, style: GoogleFonts.outfit(fontSize: 14, color: TailAdminDesign.textMuted)),
          const SizedBox(height: 8),
        ],
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
