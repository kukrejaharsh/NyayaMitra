import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_screen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _stationIdController = TextEditingController();
  final TextEditingController _rankController = TextEditingController();

  User? _user;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void fetchUserData() async {
    _user = _auth.currentUser;
    if (_user != null) {
      // Fetch user document using the user's UID
      DocumentSnapshot doc = await _firestore.collection('users').doc(_user!.uid).get();

      if (doc.exists) {
        _userData = doc.data() as Map<String, dynamic>?;

        if (_userData != null) {
          // Pre-fill the fields with existing user data
          _nameController.text = _userData!['name'] ?? '';
          _phoneNumberController.text = _userData!['phoneNumber'] ?? '';
          _stationIdController.text = _userData!['stationId']?.toString() ?? '';
          _rankController.text = _userData!['rank'] ?? '';
          setState(() {});
        }
      }
    }
  }

  Future<void> _updateProfile() async {
    if (!_isValidName(_nameController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name must contain only alphabets and cannot be empty')),
      );
      return;
    }

    if (!_isValidPhoneNumber(_phoneNumberController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number must be exactly 10 digits')),
      );
      return;
    }

    if (!_isValidStationId(_stationIdController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Station ID must be a numerical value')),
      );
      return;
    }

    if (!_isValidRank(_rankController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rank must contain only alphabets and cannot be empty')),
      );
      return;
    }

    try {
      if (_user != null) {
        // Update user data in Firestore using the UID
        await _firestore.collection('users').doc(_user!.uid).update({
          'name': _nameController.text.trim(),
          'phoneNumber': _phoneNumberController.text.trim(),
          'stationId': _stationIdController.text.trim(),
          'rank': _rankController.text.trim(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );

        // Optionally update the local userData map
        _userData!['name'] = _nameController.text.trim();
        _userData!['phoneNumber'] = _phoneNumberController.text.trim();
        _userData!['stationId'] = _stationIdController.text.trim();
        _userData!['rank'] = _rankController.text.trim();

        // Pass updated data back to ProfileScreen
        Navigator.pop(context, _userData); // Pass updated data
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
    }
  }

  bool _isValidName(String name) {
    return name.isNotEmpty && RegExp(r'^[a-zA-Z ]+$').hasMatch(name);
  }

  bool _isValidPhoneNumber(String phoneNumber) {
    return phoneNumber.length == 10 && RegExp(r'^\d{10}$').hasMatch(phoneNumber);
  }

  bool _isValidStationId(String stationId) {
    return stationId.isNotEmpty;
  }

  bool _isValidRank(String rank) {
    return rank.isNotEmpty && RegExp(r'^[a-zA-Z ]+$').hasMatch(rank);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display Default Profile Picture
              const Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/default_profile_icon.png'),
                ),
              ),
              const SizedBox(height: 16),

              // Display batch number as a header/subtitle outside the card
              if (_userData != null && _userData!['batchNumber'] != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    '      Batch Number: ${_userData!['batchNumber']}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(221, 55, 54, 54),
                    ),
                  ),
                ),

              // Input fields enclosed in a Card Widget
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildTextField(_nameController, 'Name'),
                      _buildTextField(_phoneNumberController, 'Phone Number', keyboardType: TextInputType.phone),
                      _buildTextField(_stationIdController, 'Station ID', keyboardType: TextInputType.number),
                      _buildTextField(_rankController, 'Rank'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Update Button
              Center(
                child: ElevatedButton(onPressed: _updateProfile, child: const Text('Update')),
              ),
            ],
          ),
        ),
      ),
    );
  }
  // Helper method to build a TextField with consistent styling
  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(10),
        ),
        keyboardType: keyboardType,
      ),
    );
  }
}
