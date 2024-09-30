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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile',
        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 227, 227, 247),
                          ),
        ),
        backgroundColor: const Color.fromARGB(255, 0, 51, 102),),
      body: Container(
        color: Colors.grey[100], // Set a background color for the screen
        padding: const EdgeInsets.all(16.0),
        child: _userData == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    
                    const SizedBox(height: 60),
                    // Display Default Profile Picture
                    const CircleAvatar(
                      radius: 60,
                      backgroundImage: AssetImage('assets/default_profile_icon.png'),
                    ),
                    const SizedBox(height: 60),
                    
                    // User details container
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12), // Rounded corners
                        border: Border.all(color: Colors.grey[400]!),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8.0,
                            spreadRadius: 2.0,
                            offset: Offset(2.0, 2.0),
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
                        _buildCustomButton('Logout', _logout),
                        _buildCustomButton('Edit Profile', () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                          ).then((updatedUserData) {
                            if (updatedUserData != null) {
                              setState(() {
                                _userData = updatedUserData; // Update the UI with the new user data
                              });
                            }
                          });
                        }),
                      ],
                    ),
                  ],
                ),
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

  // Custom button widget to maintain consistent styling
  Widget _buildCustomButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue, // Background color
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20), // Button padding
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30), // Rounded corners
        ),
        elevation: 5, // Add elevation
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.white, // Text color
        ),
      ),
    );
  }
}
