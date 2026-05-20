import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:nutrifit/modules/main/home/views/widgets/app_header.dart';
import 'package:nutrifit/modules/main/profile/views/support_chat_screen.dart';

class SupportTicketScreen extends StatefulWidget {
  const SupportTicketScreen({super.key});

  @override
  State<SupportTicketScreen> createState() => _SupportTicketScreenState();
}

class _SupportTicketScreenState extends State<SupportTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  String _selectedType = 'Lỗi';
  File? _selectedImage;
  bool _isSubmitting = false;

  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<String?> _uploadToCloudinary(String imagePath) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('https://api.cloudinary.com/v1_1/dhhhclbra/image/upload'));
      request.fields['upload_preset'] = 'ml_default';
      request.files.add(await http.MultipartFile.fromPath('file', imagePath));
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        return json.decode(responseData)['secure_url'];
      }
    } catch (_) {}
    return null;
  }

  Future<void> _submitTicket() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      String imageUrl = '';
      if (_selectedImage != null) {
        final uploadedUrl = await _uploadToCloudinary(_selectedImage!.path);
        if (uploadedUrl != null) {
          imageUrl = uploadedUrl;
        }
      }

      final user = FirebaseAuth.instance.currentUser;
      final userEmail = user?.email ?? 'anonymous@nutrifit.com';

      await FirebaseFirestore.instance.collection('feedbacks').add({
        'userEmail': userEmail,
        'title': _titleController.text.trim(),
        'message': _messageController.text.trim(),
        'type': _selectedType,
        'status': 'pending',
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      Get.back();
      Get.snackbar(
        'Thành công',
        'Phiếu hỗ trợ đã được gửi đi! Cảm ơn bạn đã phản hồi.',
        backgroundColor: Colors.green.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể gửi phiếu hỗ trợ: $e',
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: _isSubmitting
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: theme.colorScheme.primary),
                    const SizedBox(height: 16),
                    Text(
                      'Đang gửi phiếu hỗ trợ...',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppHeader(title: 'Phiếu hỗ trợ', showBackButton: true),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => Get.to(() => const SupportChatScreen()),
                        icon: const Icon(Icons.chat_bubble_outline),
                        label: const Text('Chat trực tiếp với CSKH', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                          foregroundColor: theme.colorScheme.primary,
                          elevation: 0,
                          minimumSize: const Size(double.infinity, 55),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Hoặc gửi phiếu hỗ trợ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF1D1517),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTypeOption('Lỗi', Icons.bug_report_outlined, theme),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _buildTypeOption('Góp ý', Icons.lightbulb_outline, theme),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _titleController,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black),
                        decoration: InputDecoration(
                          labelText: 'Tiêu đề phiếu hỗ trợ',
                          labelStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey),
                          prefixIcon: Icon(Icons.title, color: theme.colorScheme.primary),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF1E293B) : Colors.grey.shade50,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.colorScheme.primary)),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập tiêu đề';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _messageController,
                        maxLines: 5,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black),
                        decoration: InputDecoration(
                          labelText: 'Chi tiết lý do / nội dung hỗ trợ',
                          labelStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(bottom: 80.0),
                            child: Icon(Icons.message_outlined, color: theme.colorScheme.primary),
                          ),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF1E293B) : Colors.grey.shade50,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.colorScheme.primary)),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập nội dung hỗ trợ';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Hình ảnh minh họa (không bắt buộc)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: double.infinity,
                          height: 160,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark ? Colors.white10 : Colors.grey.shade300,
                              style: BorderStyle.solid,
                              width: 1.5,
                            ),
                          ),
                          child: _selectedImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.file(_selectedImage!, fit: BoxFit.cover),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_photo_alternate_outlined, size: 40, color: theme.colorScheme.primary),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Bấm để tải ảnh lên',
                                      style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey, fontSize: 12),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: _submitTicket,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          minimumSize: const Size(double.infinity, 60),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Gửi phiếu hỗ trợ',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildTypeOption(String type, IconData icon, ThemeData theme) {
    final isSelected = _selectedType == type;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? theme.colorScheme.primary.withValues(alpha: 0.1)
            : (isDark ? const Color(0xFF1E293B) : Colors.grey.shade50),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isSelected ? theme.colorScheme.primary : Colors.transparent),
      ),
      child: InkWell(
        onTap: () => setState(() => _selectedType = type),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? theme.colorScheme.primary : Colors.grey, size: 20),
              const SizedBox(width: 8),
              Text(
                type,
                style: TextStyle(
                  color: isSelected ? theme.colorScheme.primary : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
