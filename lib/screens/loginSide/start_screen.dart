import 'package:NyayaMitra/screens/loginSide/login_screen.dart';
import 'package:flutter/material.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "title": "Welcome to NyayaMitra",
      "desc": "Your trusted companion for quick and reliable legal help.",
      "image": "assets/law_logo_new.png",
    },
    {
      "title": "AI Powered Assistance",
      "desc": "Get instant answers to your legal questions using our advanced AI.",
      "image": "assets/AI.png",
    },
    {
      "title": "Legal Resources",
      "desc": "Get access to legal articles, rights info, and case studies.",
      "image": "assets/resources.png",
    },
    {
      "title": "Ask Experts",
      "desc": "Consult with lawyers directly through our secure app.",
      "image": "assets/consult.png",
    },
    {
      "title": "Stay Updated",
      "desc": "Receive important legal updates and notifications instantly.",
      "image": "assets/updates.png",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// 🔹 Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6C63FF), Color.fromARGB(255, 4, 129, 167)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          /// 🔹 Skip button (only if NOT on last page)
          if (_currentPage != onboardingData.length - 1)
            Positioned(
              top: 40,
              right: 20,
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text(
                  "Skip",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),

          /// 🔹 Onboarding content
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemCount: onboardingData.length,
                    itemBuilder: (context, index) {
                      bool isActive = index == _currentPage;

                      return AnimatedOpacity(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeInOut,
                        opacity: isActive ? 1.0 : 0.0,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                onboardingData[index]["image"]!,
                                height: 220,
                              ),
                              const SizedBox(height: 30),
                              Text(
                                onboardingData[index]["title"]!,
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 15),
                              Text(
                                onboardingData[index]["desc"]!,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                /// 🔹 Page Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    onboardingData.length,
                    (index) {
                      bool isActive = _currentPage == index;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 6,
                        width: isActive ? 28 : 12,
                        decoration: BoxDecoration(
                          color: isActive
                              ? Colors.white
                              : Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      );
                    },
                  ),
                ),

                /// 🔹 Button
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      if (_currentPage == onboardingData.length - 1) {
                        Navigator.pushReplacementNamed(context, '/login');
                      } else {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: Text(
                      _currentPage == onboardingData.length - 1
                          ? "Continue to Login"
                          : "Next",
                      style: const TextStyle(
                        fontSize: 18,
                        color: Color(0xFF003366),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
