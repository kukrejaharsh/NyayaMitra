import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:legal_info_app/constants/theme.dart'; // Import theme.dart
import 'package:legal_info_app/services/auth_service.dart';// Import ThemeNotifier
import 'package:legal_info_app/screens/login_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyD9NjXsEEhhXcsZ4_6EYhJFeoYAQl_jMSE', // Replace with your API key
      appId: '1:603170471228:android:1f47d24fdfc39602763239', // Replace with your App ID
      messagingSenderId: '603170471228', // Replace with your Messaging Sender ID
      projectId: 'legal-info-app', // Replace with your Project ID
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        ChangeNotifierProvider<ThemeNotifier>(create: (_) => ThemeNotifier()), // Add ThemeNotifier provider
      ],
      child: Consumer<ThemeNotifier>(
        builder: (context, themeNotifier, child) {
          return MaterialApp(
            title: 'LEGAL-INFO-APP',
            theme: AppTheme.lightTheme,  // Your defined light theme
            darkTheme: AppTheme.darkTheme, // Your defined dark theme
            themeMode: themeNotifier.isDarkTheme ? ThemeMode.dark : ThemeMode.light, // Theme switching logic
            home: const LoginScreen(), // Setting the LoginScreen as the initial screen
            debugShowCheckedModeBanner: false, // Hides the debug banner
          );
        },
      ),
    );
  }
}
