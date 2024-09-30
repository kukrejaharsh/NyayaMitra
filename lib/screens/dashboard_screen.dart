import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart'; // Import the flutter_tts package
import 'package:legal_info_app/widgets/drawer_menu.dart';
import 'profile_screen.dart';
import 'legal_sections_screen.dart';
import 'section_suggestion_screen.dart'; // Import the section suggestion screen

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late PageController _pageController;
  
  final FlutterTts _flutterTts = FlutterTts();
  late Timer _timer;
  int _currentPage = 0;
  final TextEditingController _descriptionController = TextEditingController(); // Controller for text field
  FlutterTts flutterTts = FlutterTts(); // Initialize FlutterTTS

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);

    // Start the timer to automatically slide images
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentPage < 1) {
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

    // Initialize text-to-speech settings
    flutterTts.setLanguage("en-US");
    flutterTts.setPitch(1.0);
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    _descriptionController.dispose(); // Dispose controller
    flutterTts.stop(); // Stop TTS if still speaking
    super.dispose();
  }

  // Method to trigger TTS and read the description
  Future<void> _speakDescription() async {

    if (_descriptionController.text.isNotEmpty) {
      await _flutterTts.setLanguage("en-IN");
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.speak(_descriptionController.text);
    } else {
      await flutterTts.speak("Please enter a description before speaking.");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine if the current theme is dark
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 227, 227, 247),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 0, 51, 102),
        iconTheme: IconThemeData(
          color: isDarkTheme ? Colors.white : const Color.fromARGB(255, 227, 227, 247)), // Set icon color
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
      body: SingleChildScrollView( // Allows for scroll in case content exceeds screen size
        child: Column(
          children: [
            // Lion logo enclosed in a blue box
            Container(
              color: const Color.fromARGB(255, 9, 74, 153), // Set the background color to blue
              padding: const EdgeInsets.all(10), // Add padding for aesthetics
              width: double.infinity, // Make it full width
              child: Center(
                // Center the image
                child: Image.asset(
                  'assets/lion_logo.png',
                  height: 80, // Adjust the height as needed
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Welcome message
            const Text(
              'NAMASTE!! Welcome to NyayaMitra',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 20),

            // Image slider
            SizedBox(
              height: 150, // Set height for the slider
              child: PageView(
                controller: _pageController,
                children: [
                  Image.asset('assets/indian_flag.png', fit: BoxFit.cover),
                  Image.asset('assets/law_logo.png', fit: BoxFit.contain),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Check the Suggested Section for any Complaint-',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),

            // Text Field for Incident Description enclosed in a box
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0), // Adds padding
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(10),
                child: TextField(
                  controller: _descriptionController, // Controller for description
                  maxLines: 7, // Make it a large input field with 7-8 lines
                  decoration: const InputDecoration(
                    labelText: 'Describe the Incident',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Mic Button for speech-to-text functionality
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity, // Full-width button
                height: 50, // Set a height for the button
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent, // Custom button color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // Rounded corners
                    ),
                    elevation: 5, // Add shadow for a modern look
                  ),
                  onPressed: () {
                     _speakDescription; // Use the _speakDescription method
                  },
                  icon: const Icon(Icons.mic,  color: Colors.white,), // Mic icon
                  label: const Text(
                    'Speak Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color:  Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Button to navigate to SectionSuggestionScreen
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity, // Full-width button
                height: 50, // Set a height for the button
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E88E5), // Custom button color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // Rounded corners
                    ),
                    elevation: 5, // Add shadow for a modern look
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SectionSuggestionScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Check Suggested Sections',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Add Map of Maharashtra text and image
            const Text(
              'Map of Maharashtra',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),
            Image.asset(
              'assets/maha_map.png',
              height: 350, // Adjust height for the image
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
