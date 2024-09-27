import 'package:flutter/material.dart';
import '../screens/profile_screen.dart';
import '../screens/complaint_input_screen.dart';
import '../screens/legal_sections_screen.dart';
import '../screens/case_summary_screen.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text('LEGAL-INFO-APP'),
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
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CaseSummaryScreen()));
            },
          ),
        ],
      ),
    );
  }
}
