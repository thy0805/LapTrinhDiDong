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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: AppHeader(title: 'Tiến độ', showBackButton: false),
            ),
            SizedBox(height: 20),
            Container(
              width: chieuRong * 0.85,
              height: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? Color(0xFF1E293B) : Color(0xFFF7F8F8),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isPhotoTab = true),
                      child: Container(
                        margin: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          gradient: _isPhotoTab
                              ? LinearGradient(
                                  colors: [
                                    Theme.of(context).colorScheme.primary,
                                    Theme.of(context).colorScheme.secondary,
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
                                  : Color(0xFFA5A3AF),
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
                        margin: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          gradient: !_isPhotoTab
                              ? LinearGradient(
                                  colors: [
                                    Theme.of(context).colorScheme.primary,
                                    Theme.of(context).colorScheme.secondary,
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
                                  : Color(0xFFA5A3AF),
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
            SizedBox(height: 20),
            Expanded(
              child: _isPhotoTab
                  ? ProgressPhotoTab()
                  : ProgressStatisticTab(),
            ),
          ],
        ),
      ),
    );
  }
}
