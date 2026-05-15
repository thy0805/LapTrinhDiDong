import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nutrifit/modules/auth/views/register_screen_1.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "title": "Theo dõi mục tiêu",
      "text":
          "Đừng lo lắng nếu bạn gặp khó khăn trong việc xác định mục tiêu. Chúng tôi có thể giúp bạn theo dõi mục tiêu của mình.",
      "image": "assets/onboard_1.svg",
    },
    {
      "title": "Đốt cháy Calo",
      "text":
          "Hãy tiếp tục đốt cháy calo để đạt được mục tiêu của bạn, sự mệt mỏi chỉ là tạm thời.",
      "image": "assets/onboard_2.svg",
    },
    {
      "title": "Ăn uống lành mạnh",
      "text":
          "Bắt đầu một lối sống lành mạnh với chúng tôi, ăn uống lành mạnh là một niềm vui.",
      "image": "assets/onboard_3.svg",
    },
    {
      "title": "Ngủ ngon mỗi ngày",
      "text":
          "Cải thiện chất lượng giấc ngủ của bạn để cơ thể được phục hồi tốt nhất.",
      "image": "assets/onboard_4.svg",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (value) {
                setState(() {
                  _currentPage = value;
                });
              },
              itemCount: onboardingData.length,
              itemBuilder: (context, index) => OnboardingContent(
                image: onboardingData[index]["image"]!,
                title: onboardingData[index]["title"]!,
                text: onboardingData[index]["text"]!,
              ),
            ),
          ),

          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (_currentPage == onboardingData.length - 1) {
                        
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterPage1(),
                          ),
                        );
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );
                      }
                    },
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: const ShapeDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(1.83, 1.93),
                          end: Alignment(-0.42, -0.44),
                          colors: [Color(0xFFCC8FED), Color(0xFF6B50F6)],
                        ),
                        shape: OvalBorder(),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingContent extends StatelessWidget {
  const OnboardingContent({
    super.key,
    required this.image,
    required this.title,
    required this.text,
  });

  final String image, title, text;

  @override
  Widget build(BuildContext context) {
    
    final size = MediaQuery.of(context).size;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        
        SvgPicture.asset(
          image,
          width: double.infinity,
          height:
              size.height *
              0.55,
          fit: BoxFit
              .cover,
        ),

        const SizedBox(height: 40),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF1D1517),
                  fontSize: 24,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                text,
                style: const TextStyle(
                  color: Color(0xFFB6B4C1),
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
