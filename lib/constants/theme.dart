import 'package:flutter/material.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    primaryColor: Colors.blue,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(color: Colors.blue), colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.blueAccent),
  );

  static final darkTheme = ThemeData(
    primaryColor: Colors.black,
    scaffoldBackgroundColor: Colors.black12,
    appBarTheme: const AppBarTheme(color: Colors.black), colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.red),
  );
}
