import 'package:NyayaMitra/all_chats_screen.dart';
import 'package:NyayaMitra/models/user_model';
import 'package:NyayaMitra/screens/clientSide/choose_lawyer_screen.dart';
import 'package:NyayaMitra/screens/clientSide/lawyer_list_screen.dart';
import 'package:NyayaMitra/screens/lawyerSide/lawyer_dashboard_screen.dart';
import 'package:NyayaMitra/services/db_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:NyayaMitra/services/auth_service.dart';
import 'package:provider/provider.dart';  
import 'package:NyayaMitra/screens/loginSide/login_screen.dart';
import 'package:NyayaMitra/screens/clientSide/client_dashboard_screen.dart';
import 'package:NyayaMitra/screens/profile_screen.dart' ;
import 'package:NyayaMitra/screens/scan_doc_screen.dart' ;
import 'package:NyayaMitra/screens/clientSide/new_case_screen.dart' ;
import 'package:NyayaMitra/screens/clientSide/ask_ai_screen.dart' ;
import 'package:NyayaMitra/screens/clientSide/all_cases_screen.dart' ;
import 'package:NyayaMitra/screens/loginSide/start_screen.dart' ;



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Secure, auto-picks config from google-services.json
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
      ],
      child: Consumer<AuthService>( builder: (context, themeNotifier, child) { 
        return
          MaterialApp(
            title: 'Nyaya-Mitra',
            debugShowCheckedModeBanner: false,
            home: const AuthGate(), // Handles persistent login
            // home: const start.StartScreen(), // Handles persistent login
            // home: const LoginScreen(), // Handles persistent login
            routes: {
              '/profile': (_) => const ProfileScreen(),
              '/login': (_) => const LoginScreen(),
              '/scan-doc': (_) => const ScanDocScreen(),
              '/new-case': (_) => const NewCaseScreen(),
              '/ask-ai': (_) => const AskAiScreen(),
              '/all-cases': (_) => const AllCasesScreen(),
              '/start': (_) => const StartScreen(),
              '/choose-lawyer': (_) => const ChooseLawyerScreen(),
              '/home-screen': (_) => const ClientDashboardScreen(),
              '/lawyer-list': (_) => const LawyerListScreen(),
              '/all-chats': (_) => const AllChatsScreen(),
            },
          );
      }),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        // If the connection is still loading, show a basic splash screen.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If a user is logged in, use the RoleDispatcher to show the correct screen.
        if (snapshot.hasData) {
          return _RoleDispatcher(user: snapshot.data!);
        }
        
        // If no user is logged in, show the initial start/login screen.
        else {
          return const StartScreen();
        }
      },
    );
  }
}


/// This is a helper widget that fetches the user's role from Firestore
/// and directs them to the appropriate dashboard.
class _RoleDispatcher extends StatefulWidget {
  final User user;
  const _RoleDispatcher({required this.user});

  @override
  State<_RoleDispatcher> createState() => _RoleDispatcherState();
}

class _RoleDispatcherState extends State<_RoleDispatcher> {
  late Future<UserModel?> _userModelFuture;
  final DbService _dbService = DbService();

  @override
  void initState() {
    super.initState();
    // Fetch the user's full profile from the database using their UID.
    _userModelFuture = _dbService.getUserProfile(widget.user.uid);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: _userModelFuture,
      builder: (context, snapshot) {
        // While fetching the role, show a loading screen.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If there's an error or the user's document doesn't exist in Firestore.
        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          // You could show an error screen here or log the user out.
          // For now, we default to the client home screen.
          return const ClientDashboardScreen();
        }

        final userModel = snapshot.data!;

        // ✅ THE CORE LOGIC: Check the user's role and return the correct screen.
        if (userModel.role == 'lawyer') {
          return const LawyerDashboardScreen();
        } else {
          // Defaults to HomeScreen for 'client' or any other role.
          return const ClientDashboardScreen();
        }
      },
    );
  }
}
