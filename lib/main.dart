import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:legal_info_app/constants/theme.dart';
import 'package:legal_info_app/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyD9NjXsEEhhXcsZ4_6EYhJFeoYAQl_jMSE', // paste your api key here
      appId: '1:603170471228:android:1f47d24fdfc39602763239', //paste your app id here
      messagingSenderId: '603170471228', //paste your messagingSenderId here
      projectId: 'legal-info-app', //paste your project id here
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
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: MaterialApp(
        title: 'LEGAL-INFO-APP',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: const LoginScreen(),
      ),
    );
  }
}

