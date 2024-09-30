import 'dart:async';
import 'package:flutter/material.dart';
import 'package:legal_info_app/widgets/drawer_menu.dart';
import 'profile_screen.dart';
import 'legal_sections_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late PageController _pageController;
  late Timer _timer;
  int _currentPage = 0;

 @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);

    // Start the timer to automatically slide images
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentPage < 2) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeIn,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine if the current theme is dark
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        iconTheme: IconThemeData(color: isDarkTheme ? Colors.white : Colors.black), // Set icon color
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      drawer: const DrawerMenu(),
      body: Column(
        children: [
                SizedBox(
            height: 150, // Set height for the slider
            child: PageView(
              controller: _pageController,
              children: [
                Image.asset('assets/indian_flag.png', fit: BoxFit.cover),
                Image.asset('assets/lion_logo.png', fit: BoxFit.contain),
                Image.asset('assets/law_logo.png', fit: BoxFit.contain),
              ],
            ),
          ),
          // Welcome message
          const Text(
            'Welcome to NyayaMitra',
            style: TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 20),
          // Buttons to navigate to different sections
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
            child: const Text('Profile'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LegalSectionsScreen()),
            ),
            child: const Text('Legal Sections'),
          ),
        ],
      ),
    );
  }
}
