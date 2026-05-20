import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutrifit_admin/core/theme/tailadmin_design_system.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hồ sơ của tôi',
          style: GoogleFonts.outfit(
            fontSize: TailAdminDesign.font2xl,
            fontWeight: FontWeight.bold,
            color: TailAdminDesign.textMain,
          ),
        ),
        const SizedBox(height: TailAdminDesign.sp8),
        Container(
          padding: const EdgeInsets.all(TailAdminDesign.sp6),
          decoration: BoxDecoration(
            color: TailAdminDesign.bgCard,
            borderRadius: BorderRadius.circular(TailAdminDesign.radiusLg),
            border: Border.all(color: TailAdminDesign.border),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: const DecorationImage(
                        image: NetworkImage('https://ui-avatars.com/api/?name=Admin+NutriFit&background=465FFF&color=fff'),
                        fit: BoxFit.cover,
                      ),
                      border: Border.all(color: TailAdminDesign.brand500, width: 3),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin NutriFit',
                        style: GoogleFonts.outfit(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: TailAdminDesign.textMain,
                        ),
                      ),
                      Text(
                        'Quản trị viên cấp cao',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          color: TailAdminDesign.brand500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Chỉnh sửa'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TailAdminDesign.brand500,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(TailAdminDesign.radiusMd)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 32),
              _buildInfoRow('Email', 'admin@nutrifit.com'),
              _buildInfoRow('Số điện thoại', '090 123 4567'),
              _buildInfoRow('Địa chỉ', 'TP. Hồ Chí Minh, Việt Nam'),
              _buildInfoRow('Ngày tham gia', '04/05/2026'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          SizedBox(
            width: 200,
            child: Text(
              label,
              style: GoogleFonts.outfit(
                color: TailAdminDesign.textMuted,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: TailAdminDesign.textMain,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
