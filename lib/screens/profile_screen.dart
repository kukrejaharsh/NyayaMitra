import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart'; // Import the edit profile screen

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  Map<String, dynamic>? _userData;

  void fetchUserData() async {
    _user = _auth.currentUser;
    if (_user != null) {
      DocumentSnapshot doc = await _firestore.collection('users').doc(_user!.uid).get();
      setState(() {
        _userData = doc.data() as Map<String, dynamic>?;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void _logout() async {
    await _auth.signOut();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  void _forgotPassword() async {
    if (_user != null) {
      await _auth.sendPasswordResetEmail(email: _user!.email!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent')),
      );
    }
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('Profile')),
    body: _userData == null
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Display Default Profile Picture
                CircleAvatar(
                  radius: 50,
                  backgroundImage: const AssetImage('assets/default_profile_icon.png'),
                ),
                const SizedBox(height: 16),
                const SizedBox(height: 30),

                // User details
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8.0,
                        spreadRadius: 2.0,
                        offset: const Offset(2.0, 2.0),
                      ),
                    ],
                    color: Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileField('Name', _userData!['name']),
                      const SizedBox(height: 10),
                      _buildProfileField('Batch Number', _userData!['batchNumber']),
                      const SizedBox(height: 10),
                      _buildProfileField('Email', _user!.email),
                      const SizedBox(height: 10),
                      _buildProfileField('Rank', _userData!['rank']),
                      const SizedBox(height: 10),
                      _buildProfileField('Phone Number', _userData!['phoneNumber']),
                      const SizedBox(height: 10),
                      _buildProfileField('Station ID', _userData!['stationId']),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Logout and Edit Profile buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: _logout,
                      child: const Text('Logout'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                        ).then((updatedUserData) {
                          if (updatedUserData != null) {
                            setState(() {
                              _userData = updatedUserData;  // Update the UI with the new user data
                            });
                          }
                        });
                      },
                      child: const Text('Edit Profile'),
                    ),
                  ],
                ),
              ],
            ),
          ),
  );
}


  // Method to build profile fields in bold for key, normal for value
  Widget _buildProfileField(String fieldName, String? value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$fieldName: ',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Flexible(
          child: Text(
            value ?? 'N/A',
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ],
    );
  }
}
