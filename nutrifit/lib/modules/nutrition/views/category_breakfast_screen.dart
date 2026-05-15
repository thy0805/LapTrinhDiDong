import 'package:flutter/material.dart';
import 'package:nutrifit/modules/nutrition/views/meal_details_screen.dart';

class CategoryBreakfastScreen extends StatelessWidget {
  const CategoryBreakfastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final kichThuoc = MediaQuery.of(context).size;
    final chieuRong = kichThuoc.width;
    final chieuCao = kichThuoc.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF1D1517),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Bữa sáng',
          style: TextStyle(
            color: Color(0xFF1D1517),
            fontSize: 16,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Color(0xFF1D1517)),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: chieuRong * 0.08,
          vertical: chieuCao * 0.02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x111D1617),
                    blurRadius: 40,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Tìm kiếm món bánh Pancake',
                  hintStyle: TextStyle(
                    color: Color(0xFFC6C4D3),
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  ),
                  icon: Icon(Icons.search, color: Color(0xFFA5A3AF)),
                  suffixIcon: Icon(Icons.filter_list, color: Color(0xFFA5A3AF)),
                ),
              ),
            ),
            SizedBox(height: chieuCao * 0.03),
            const Text(
              'Thể loại',
              style: TextStyle(
                color: Color(0xFF1D1517),
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
            SizedBox(height: chieuCao * 0.02),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                children: [
                  _taoOTheLoai('Salad', const [
                    Color(0xFF00FF66),
                    Color(0xFF00EFFF),
                  ]),
                  _taoOTheLoai('Bánh ngọt', const [
                    Color(0xFFC050F6),
                    Color(0xFFEEA4CE),
                  ]),
                  _taoOTheLoai('Bánh nướng', const [
                    Color(0xFF00FF66),
                    Color(0xFF00EFFF),
                  ]),
                  _taoOTheLoai('Sinh tố', const [
                    Color(0xFFC050F6),
                    Color(0xFFEEA4CE),
                  ]),
                ],
              ),
            ),
            SizedBox(height: chieuCao * 0.03),
            const Text(
              'Gợi ý cho Chế độ ăn kiêng',
              style: TextStyle(
                color: Color(0xFF1D1517),
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
            SizedBox(height: chieuCao * 0.02),
            SizedBox(
              height: 240,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                children: [
                  _taoGoiYMonAn(
                    context,
                    'Bánh Pancake Mật ong',
                    'Dễ | 30 Phút | 180kCal',
                    const [Color(0xFF00FF66), Color(0xFF00EFFF)],
                    'assets/honey_pancake.png',
                  ),
                  _taoGoiYMonAn(
                    context,
                    'Bánh mì Canai',
                    'Dễ | 20 Phút | 230kCal',
                    const [Color(0xFFC050F6), Color(0xFFEEA4CE)],
                    'assets/canai_bread.png',
                  ),
                ],
              ),
            ),
            SizedBox(height: chieuCao * 0.03),
            const Text(
              'Phổ biến',
              style: TextStyle(
                color: Color(0xFF1D1517),
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
            SizedBox(height: chieuCao * 0.02),
            _taoItemPhoBien(
              context,
              'Bánh Pancake Việt quất',
              'Vừa | 30 Phút | 230kCal',
              'assets/blueberry_pancake.png',
            ),
            _taoItemPhoBien(
              context,
              'Sushi Cá hồi',
              'Vừa | 20 Phút | 120kCal',
              'assets/salmon_nigiri.png',
            ),
          ],
        ),
      ),
    );
  }

  Widget _taoOTheLoai(String ten, List<Color> mauNen) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            mauNen[0].withValues(alpha: 0.2),
            mauNen[1].withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.fastfood, color: mauNen[0], size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            ten,
            style: const TextStyle(
              color: Color(0xFF1D1517),
              fontSize: 12,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _taoGoiYMonAn(
    BuildContext context,
    String ten,
    String moTa,
    List<Color> mauNen,
    String hinhAnh,
  ) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            mauNen[0].withValues(alpha: 0.2),
            mauNen[1].withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Image.asset(
            hinhAnh,
            height: 80,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                Icon(Icons.breakfast_dining, size: 80, color: mauNen[0]),
          ),
          const Spacer(),
          Text(
            ten,
            style: const TextStyle(
              color: Color(0xFF1D1517),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 5),
          Text(
            moTa,
            style: const TextStyle(
              color: Color(0xFFB6B4C1),
              fontSize: 12,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 15),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MealDetailsScreen(),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: mauNen),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Text(
                'Xem',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _taoItemPhoBien(
    BuildContext context,
    String ten,
    String moTa,
    String hinhAnh,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MealDetailsScreen()),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x111D1617),
              blurRadius: 40,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8F8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(
                hinhAnh,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.fastfood, color: Color(0xFFB6B4C1)),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ten,
                    style: const TextStyle(
                      color: Color(0xFF1D1517),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    moTa,
                    style: const TextStyle(
                      color: Color(0xFFB6B4C1),
                      fontSize: 12,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFFA5A3AF),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}
