import 'package:flutter/material.dart';
import 'package:nutrifit/modules/main/progress/views/progress_photo_tab.dart';
import 'package:nutrifit/modules/main/progress/views/progress_statistic_tab.dart';
import 'package:nutrifit/modules/main/home/views/widgets/app_header.dart';

class ProgressTrackerScreen extends StatefulWidget {
  const ProgressTrackerScreen({super.key});

  @override
  State<ProgressTrackerScreen> createState() => _ProgressTrackerScreenState();
}

class _ProgressTrackerScreenState extends State<ProgressTrackerScreen> {
  bool _isPhotoTab = true;

  @override
  Widget build(BuildContext context) {
    final chieuRong = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: AppHeader(title: 'Tiến độ', showBackButton: false),
            ),
            const SizedBox(height: 20),
            Container(
              width: chieuRong * 0.85,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8F8),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isPhotoTab = true),
                      child: Container(
                        margin: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          gradient: _isPhotoTab
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFFC050F6),
                                    Color(0xFFEEA4CE),
                                  ],
                                )
                              : null,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Center(
                          child: Text(
                            'Hình ảnh',
                            style: TextStyle(
                              color: _isPhotoTab
                                  ? Colors.white
                                  : const Color(0xFFA5A3AF),
                              fontSize: 14,
                              fontFamily: 'Poppins',
                              fontWeight: _isPhotoTab
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isPhotoTab = false),
                      child: Container(
                        margin: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          gradient: !_isPhotoTab
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFFC050F6),
                                    Color(0xFFEEA4CE),
                                  ],
                                )
                              : null,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Center(
                          child: Text(
                            'Thống kê',
                            style: TextStyle(
                              color: !_isPhotoTab
                                  ? Colors.white
                                  : const Color(0xFFA5A3AF),
                              fontSize: 14,
                              fontFamily: 'Poppins',
                              fontWeight: !_isPhotoTab
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _isPhotoTab
                  ? const ProgressPhotoTab()
                  : const ProgressStatisticTab(),
            ),
          ],
        ),
      ),
    );
  }
}
