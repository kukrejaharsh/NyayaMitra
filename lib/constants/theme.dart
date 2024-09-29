import 'package:flutter/material.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    primaryColor: Colors.blue,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(color: Colors.blue),
    colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.blueAccent),

    // Updated TextTheme for light mode
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: Colors.black), // Heading text color
      bodyLarge: TextStyle(color: Colors.black), // Main body text color
      bodyMedium: TextStyle(color: Colors.black), // Secondary body text color
    ),

    // General brightness setting
    brightness: Brightness.light,
  );

  static final darkTheme = ThemeData(
    primaryColor: Colors.black,
    scaffoldBackgroundColor: const Color(0xFF1E1E1E), // Dark grey background (similar to ChatGPT's dark mode)
    appBarTheme: const AppBarTheme(color: Colors.black),

    colorScheme: ColorScheme.fromSwatch().copyWith(
      secondary: Colors.red,
      brightness: Brightness.dark,
    ),

    // Updated TextTheme for dark mode
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: Colors.white), // Heading text color
      bodyLarge: TextStyle(color: Colors.white), // Main body text color
      bodyMedium: TextStyle(color: Colors.white), // Secondary body text color
    ),

    // General brightness setting
    brightness: Brightness.dark,
  );
}

class ThemeNotifier extends ChangeNotifier {
  bool _isDarkTheme = false;

  bool get isDarkTheme => _isDarkTheme;

  ThemeData get currentTheme => _isDarkTheme ? AppTheme.darkTheme : AppTheme.lightTheme;

  void toggleTheme() {
    _isDarkTheme = !_isDarkTheme;
    notifyListeners();  // Notify listeners to rebuild the UI
  }
}
