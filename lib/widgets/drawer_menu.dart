import 'package:flutter/material.dart';
import 'package:legal_info_app/constants/theme.dart';
import 'package:legal_info_app/screens/login_screen.dart';
import 'package:legal_info_app/screens/view_all_cases_screen.dart';
import 'package:provider/provider.dart';
import '../screens/profile_screen.dart';
import '../screens/complaint_input_screen.dart';
import '../screens/legal_sections_screen.dart';
import '../services/auth_service.dart'; // Import your AuthService for sign out

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color:  Color.fromARGB(255, 0, 51, 102),),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center, // Center the content
              children: [
                const Text(
                  'NYAYA-MITRA',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
                const SizedBox(height: 10), // Add some space between the text and the logo
                Image.asset(
                  'assets/law_logo.png', // Path to your law logo image
                  height: 80, // Adjust the height as needed
                  fit: BoxFit.contain, // Maintain the aspect ratio
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.book),
            title: const Text('Legal Sections'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const LegalSectionsScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('File Complaint'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ComplaintInputScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('View All Cases'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ViewAllCasesScreen()));
            },
          ),
          // Settings Dropdown Menu
          ExpansionTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.brightness_6),
                title: const Text('Change Theme'),
                onTap: () {
                  // Toggle the theme using ThemeNotifier
                  Provider.of<ThemeNotifier>(context, listen: false).toggleTheme();
                  Navigator.pop(context);  // Close drawer after the theme change
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Sign Out'),
                onTap: () {
                  // Call sign out method from AuthService
                  Provider.of<AuthService>(context, listen: false).signOut();
                  
                  // Navigate to login screen after signing out
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
