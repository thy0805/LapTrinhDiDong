import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutrifit_admin/core/theme/app_colors.dart';
import 'package:nutrifit_admin/core/theme/app_animations.dart';
import 'package:nutrifit_admin/core/theme/tailadmin_design_system.dart';
import 'package:nutrifit_admin/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:nutrifit_admin/modules/users/controllers/user_management_controller.dart';
import 'package:nutrifit_admin/modules/dashboard/views/dashboard_screen.dart';
import 'package:nutrifit_admin/modules/users/views/user_management_screen.dart';
import 'package:nutrifit_admin/modules/nutrition/views/food_management_screen.dart';
import 'package:nutrifit_admin/modules/workout/views/workout_management_screen.dart';
import 'package:nutrifit_admin/modules/cms/views/cms_screen.dart';
import 'package:nutrifit_admin/modules/notifications/views/notification_screen.dart';
import 'package:nutrifit_admin/modules/feedback/views/feedback_screen.dart';
import 'package:nutrifit_admin/modules/chat/views/admin_chat_screen.dart';

import 'package:nutrifit_admin/modules/profile/views/profile_screen.dart';

import 'package:nutrifit_admin/modules/nutrition/controllers/food_management_controller.dart';
import 'package:nutrifit_admin/modules/workout/controllers/workout_management_controller.dart';

class NavigationController extends GetxController {
  var selectedIndex = 0.obs;
  var isSidebarCollapsed = false.obs;
  var isDarkMode = false.obs;
  var expandedMenu = ''.obs;

  @override
  void onInit() {
    super.onInit();
    isDarkMode.value = Get.isDarkMode;

    Get.put(DashboardController());
    Get.lazyPut(() => UserManagementController());
    Get.lazyPut(() => FoodManagementController());
    Get.lazyPut(() => WorkoutManagementController());
  }

  final List<Widget> screens = [
    const DashboardScreen(),
    const UserManagementScreen(),
    const FoodManagementScreen(),
    const WorkoutManagementScreen(),
    const CMSScreen(),
    const NotificationScreen(),
    const FeedbackScreen(),
    const ProfileScreen(),
    const AdminChatScreen(),
  ];

  void changeIndex(int index) {
    selectedIndex.value = index;
  }

  void toggleSidebar() {
    isSidebarCollapsed.value = !isSidebarCollapsed.value;
  }

  void toggleMenu(String menuName) {
    if (expandedMenu.value == menuName) {
      expandedMenu.value = '';
    } else {
      expandedMenu.value = menuName;
    }
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }
}

class AdminLayout extends StatelessWidget {
  const AdminLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final NavigationController navBarController =
        Get.find<NavigationController>();

    return Obx(
      () => Scaffold(
        backgroundColor: AppColors.background,
        body: Row(
          children: [
            const AdminSidebar(),
            Expanded(
              child: Column(
                children: [
                  const AdminHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Container(
                        padding: const EdgeInsets.all(TailAdminDesign.sp6),
                        child: navBarController
                            .screens[navBarController.selectedIndex.value],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminSidebar extends StatelessWidget {
  const AdminSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final NavigationController navBarController =
        Get.find<NavigationController>();

    return Obx(
      () => AnimatedContainer(
        duration: AppAnimations.normal,
        curve: AppAnimations.decelerate,
        width: navBarController.isSidebarCollapsed.value ? 90 : 290,
        decoration: BoxDecoration(
          color: TailAdminDesign.bgCard,
          border: Border(
            right: BorderSide(color: TailAdminDesign.border, width: 1),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: navBarController.isSidebarCollapsed.value
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: TailAdminDesign.brand500,
                      borderRadius: BorderRadius.circular(
                        TailAdminDesign.radiusLg,
                      ),
                    ),
                    child: const Icon(
                      Icons.fitness_center_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  if (!navBarController.isSidebarCollapsed.value) ...[
                    const SizedBox(width: 12),
                    Text(
                      'NutriFit',
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: TailAdminDesign.textMain,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildSectionTitle(
                    'MENU',
                    navBarController.isSidebarCollapsed.value,
                  ),
                  _SidebarItem(
                    icon: Icons.grid_view_rounded,
                    title: 'Dashboard',
                    isActive: navBarController.selectedIndex.value == 0,
                    onTap: () => navBarController.changeIndex(0),
                    isCollapsed: navBarController.isSidebarCollapsed.value,
                  ),
                  _SidebarItem(
                    icon: Icons.people_outline_rounded,
                    title: 'Người dùng',
                    isActive: navBarController.selectedIndex.value == 1,
                    onTap: () => navBarController.changeIndex(1),
                    isCollapsed: navBarController.isSidebarCollapsed.value,
                  ),
                  _SidebarItem(
                    icon: Icons.restaurant_rounded,
                    title: 'Dinh dưỡng',
                    isActive: navBarController.selectedIndex.value == 2,
                    isCollapsed: navBarController.isSidebarCollapsed.value,
                    hasSubmenu: true,
                    isExpanded:
                        navBarController.expandedMenu.value == 'Dinh dưỡng',
                    onTap: () {
                      if (navBarController.isSidebarCollapsed.value) {
                        navBarController.changeIndex(2);
                      } else {
                        navBarController.toggleMenu('Dinh dưỡng');
                      }
                    },
                    subItems: [
                      _SidebarSubItem(
                        title: 'Thực phẩm',
                        isActive:
                            navBarController.selectedIndex.value == 2 &&
                            Get.find<FoodManagementController>()
                                    .activeTab
                                    .value ==
                                0,
                        onTap: () {
                          Get.find<FoodManagementController>().activeTab.value =
                              0;
                          navBarController.changeIndex(2);
                        },
                      ),
                      _SidebarSubItem(
                        title: 'Duyệt món ăn',
                        isActive:
                            navBarController.selectedIndex.value == 2 &&
                            Get.find<FoodManagementController>()
                                    .activeTab
                                    .value ==
                                1,
                        onTap: () {
                          Get.find<FoodManagementController>().activeTab.value =
                              1;
                          navBarController.changeIndex(2);
                        },
                      ),
                    ],
                  ),
                  _SidebarItem(
                    icon: Icons.fitness_center_rounded,
                    title: 'Bài tập',
                    isActive: navBarController.selectedIndex.value == 3,
                    isCollapsed: navBarController.isSidebarCollapsed.value,
                    hasSubmenu: true,
                    isExpanded:
                        navBarController.expandedMenu.value == 'Bài tập',
                    onTap: () {
                      if (navBarController.isSidebarCollapsed.value) {
                        navBarController.changeIndex(3);
                      } else {
                        navBarController.toggleMenu('Bài tập');
                      }
                    },
                    subItems: [
                      _SidebarSubItem(
                        title: 'Danh sách bài tập',
                        isActive: navBarController.selectedIndex.value == 3,
                        onTap: () => navBarController.changeIndex(3),
                      ),
                    ],
                  ),
                  _SidebarItem(
                    icon: Icons.article_outlined,
                    title: 'Quản trị CMS',
                    isActive: navBarController.selectedIndex.value == 4,
                    onTap: () => navBarController.changeIndex(4),
                    isCollapsed: navBarController.isSidebarCollapsed.value,
                  ),
                  _SidebarItem(
                    icon: Icons.notifications_active_outlined,
                    title: 'Thông báo Push',
                    isActive: navBarController.selectedIndex.value == 5,
                    onTap: () => navBarController.changeIndex(5),
                    isCollapsed: navBarController.isSidebarCollapsed.value,
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle(
                    'HỖ TRỢ',
                    navBarController.isSidebarCollapsed.value,
                  ),
                  _SidebarItem(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: 'Phản hồi & Lỗi',
                    isActive: navBarController.selectedIndex.value == 6,
                    onTap: () => navBarController.changeIndex(6),
                    isCollapsed: navBarController.isSidebarCollapsed.value,
                  ),
                  _SidebarItem(
                    icon: Icons.forum_outlined,
                    title: 'CSKH Trực Tuyến',
                    isActive: navBarController.selectedIndex.value == 8,
                    onTap: () => navBarController.changeIndex(8),
                    isCollapsed: navBarController.isSidebarCollapsed.value,
                  ),
                  _SidebarItem(
                    icon: Icons.settings_outlined,
                    title: 'Cài đặt',
                    isActive: false,
                    onTap: () {},
                    isCollapsed: navBarController.isSidebarCollapsed.value,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isCollapsed) {
    return Padding(
      padding: EdgeInsets.only(left: isCollapsed ? 0 : 8, bottom: 12, top: 12),
      child: isCollapsed
          ? Center(
              child: Container(
                width: 20,
                height: 1,
                color: TailAdminDesign.border,
              ),
            )
          : Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: TailAdminDesign.textMuted,
                letterSpacing: 1.2,
              ),
            ),
    );
  }
}

class _SidebarItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final bool isActive;
  final VoidCallback onTap;
  final bool isCollapsed;
  final bool hasSubmenu;
  final bool isExpanded;
  final List<Widget>? subItems;

  const _SidebarItem({
    required this.icon,
    required this.title,
    required this.isActive,
    required this.onTap,
    required this.isCollapsed,
    this.hasSubmenu = false,
    this.isExpanded = false,
    this.subItems,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: TailAdminDesign.durationFast,
              margin: const EdgeInsets.symmetric(vertical: 2),
              padding: EdgeInsets.symmetric(
                horizontal: widget.isCollapsed ? 0 : 12,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: widget.isActive
                    ? TailAdminDesign.brand500.withValues(alpha: 0.1)
                    : (_isHovered ? TailAdminDesign.hover : Colors.transparent),
                borderRadius: BorderRadius.circular(TailAdminDesign.radiusMd),
              ),
              child: Row(
                mainAxisAlignment: widget.isCollapsed
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: [
                  Icon(
                    widget.icon,
                    color: widget.isActive
                        ? TailAdminDesign.brand500
                        : (_isHovered
                              ? TailAdminDesign.textMain
                              : TailAdminDesign.textMuted),
                    size: 22,
                  ),
                  if (!widget.isCollapsed) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: widget.isActive
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: widget.isActive
                              ? TailAdminDesign.brand500
                              : (_isHovered
                                    ? TailAdminDesign.textMain
                                    : TailAdminDesign.textMuted),
                        ),
                      ),
                    ),
                    if (widget.hasSubmenu)
                      AnimatedRotation(
                        turns: widget.isExpanded ? 0.25 : 0,
                        duration: TailAdminDesign.durationFast,
                        child: Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: _isHovered
                              ? TailAdminDesign.textMain
                              : TailAdminDesign.textMuted,
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ),
        if (widget.hasSubmenu && widget.isExpanded && !widget.isCollapsed)
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Column(children: widget.subItems ?? []),
          ),
      ],
    );
  }
}

class _SidebarSubItem extends StatefulWidget {
  final String title;
  final bool isActive;
  final VoidCallback onTap;

  const _SidebarSubItem({
    required this.title,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_SidebarSubItem> createState() => _SidebarSubItemState();
}

class _SidebarSubItemState extends State<_SidebarSubItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: TailAdminDesign.durationFast,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(TailAdminDesign.radiusMd),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: widget.isActive
                        ? FontWeight.w600
                        : FontWeight.w500,
                    color: widget.isActive
                        ? TailAdminDesign.brand500
                        : (_isHovered
                              ? TailAdminDesign.textMain
                              : TailAdminDesign.textMuted),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdminHeader extends StatelessWidget {
  const AdminHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final NavigationController navBarController =
        Get.find<NavigationController>();
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool showSearch = screenWidth > 750;
    final bool showProfileText = screenWidth > 600;

    return Obx(
      () => Container(
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: TailAdminDesign.bgCard,
          border: Border(
            bottom: BorderSide(color: TailAdminDesign.border, width: 1),
          ),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () => navBarController.toggleSidebar(),
              icon: Icon(
                navBarController.isSidebarCollapsed.value
                    ? Icons.menu_open_rounded
                    : Icons.menu_rounded,
                color: TailAdminDesign.textMain,
              ),
            ),
            const SizedBox(width: 16),
            if (showSearch) ...[
              Expanded(
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: TailAdminDesign.isDark
                        ? TailAdminDesign.darkBg
                        : TailAdminDesign.gray50,
                    borderRadius: BorderRadius.circular(
                      TailAdminDesign.radiusLg,
                    ),
                    border: Border.all(color: TailAdminDesign.border),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search_rounded,
                        color: TailAdminDesign.textMuted,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          style: GoogleFonts.outfit(
                            color: TailAdminDesign.textMain,
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Tìm kiếm dữ liệu (Cmd + K)',
                            hintStyle: GoogleFonts.outfit(
                              color: TailAdminDesign.textMuted,
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 32),
            ] else ...[
              const Spacer(),
            ],
            _HeaderIcon(
              icon: navBarController.isDarkMode.value
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
              onTap: () => navBarController.toggleTheme(),
              isActive: false,
            ),
            const SizedBox(width: 12),
            Stack(
              children: [
                _HeaderIcon(
                  icon: Icons.notifications_none_rounded,
                  onTap: () {},
                  isActive: false,
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: TailAdminDesign.danger,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: TailAdminDesign.bgCard,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 24),
            const VerticalDivider(indent: 24, endIndent: 24, width: 1),
            const SizedBox(width: 24),
            PopupMenuButton<int>(
              offset: const Offset(0, 60),
              color: TailAdminDesign.bgCard,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(TailAdminDesign.radiusMd),
                side: BorderSide(color: TailAdminDesign.border),
              ),
              elevation: 10,
              onSelected: (value) {
                if (value == 0) {
                  navBarController.changeIndex(7);
                } else if (value == 3) {
                  Get.snackbar('Thông báo', 'Đã đăng xuất tài khoản Admin');
                }
              },
              itemBuilder: (context) => [
                _buildDropdownHeader(),
                const PopupMenuDivider(),
                _buildDropdownItem(
                  0,
                  Icons.person_outline_rounded,
                  'Hồ sơ của tôi',
                ),
                const PopupMenuDivider(),
                _buildDropdownItem(
                  3,
                  Icons.logout_rounded,
                  'Đăng xuất',
                  isDanger: true,
                ),
              ],
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Row(
                  children: [
                    if (showProfileText) ...[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Admin NutriFit',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: TailAdminDesign.textMain,
                            ),
                          ),
                          Text(
                            'Hệ thống quản trị',
                            style: GoogleFonts.outfit(
                              color: TailAdminDesign.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                    ],
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: const DecorationImage(
                          image: NetworkImage(
                            'https://ui-avatars.com/api/?name=Admin+NutriFit&background=465FFF&color=fff',
                          ),
                          fit: BoxFit.cover,
                        ),
                        border: Border.all(
                          color: TailAdminDesign.brand500,
                          width: 2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: TailAdminDesign.textMuted,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<int> _buildDropdownHeader() {
    return PopupMenuItem<int>(
      enabled: false,
      child: Container(
        width: 200,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Admin NutriFit',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                color: TailAdminDesign.textMain,
              ),
            ),
            Text(
              'admin@nutrifit.com',
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: TailAdminDesign.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<int> _buildDropdownItem(
    int value,
    IconData icon,
    String title, {
    bool isDanger = false,
  }) {
    return PopupMenuItem<int>(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isDanger
                ? TailAdminDesign.danger
                : TailAdminDesign.textMuted,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: isDanger
                  ? TailAdminDesign.danger
                  : TailAdminDesign.textMain,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderIcon extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;

  const _HeaderIcon({
    required this.icon,
    required this.onTap,
    required this.isActive,
  });

  @override
  State<_HeaderIcon> createState() => _HeaderIconState();
}

class _HeaderIconState extends State<_HeaderIcon> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: TailAdminDesign.durationFast,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _isHovered ? TailAdminDesign.hover : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: _isHovered ? TailAdminDesign.border : Colors.transparent,
            ),
          ),
          child: Icon(widget.icon, color: TailAdminDesign.textMuted, size: 22),
        ),
      ),
    );
  }
}
