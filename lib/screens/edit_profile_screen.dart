import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  final TextEditingController _batchNumberController = TextEditingController(); // Added controller for Batch Number

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
          _batchNumberController.text = _userData!['batchNumber']?.toString() ?? ''; // Set batch number
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

    // You can also validate batch number if needed
    if (!_isValidBatchNumber(_batchNumberController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Batch Number must be a numerical value')),
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
          'batchNumber': _batchNumberController.text.trim(), // Update batch number
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );

        // Optionally update the local userData map
        _userData!['name'] = _nameController.text.trim();
        _userData!['phoneNumber'] = _phoneNumberController.text.trim();
        _userData!['stationId'] = _stationIdController.text.trim();
        _userData!['rank'] = _rankController.text.trim();
        _userData!['batchNumber'] = _batchNumberController.text.trim(); // Update local batch number

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

  bool _isValidBatchNumber(String batchNumber) {
    return batchNumber.isNotEmpty; // You can add additional validation if needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile',
        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 227, 227, 247),
                          ),
        ),
        backgroundColor: const Color.fromARGB(255, 0, 51, 102),),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              // Display Default Profile Picture
              const Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage('assets/default_profile_icon.png'),
                ),
              ),
              const SizedBox(height: 30),

              // Display batch number as a header/subtitle outside the card
              if (_userData != null && _userData!['batchNumber'] != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
                  child: Text(
                    'Batch Number: ${_userData!['batchNumber']}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(221, 0, 0, 0),
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
                      _buildTextField(_batchNumberController, 'Batch Number', keyboardType: TextInputType.number), // Added batch number field
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Update Button
Center(
  child: Container(
    width: double.infinity, // Make the button take full width
    margin: const EdgeInsets.symmetric(vertical: 20), // Add vertical margin
    child: ElevatedButton(
      onPressed: _updateProfile,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white, backgroundColor: Colors.blue, padding: const EdgeInsets.symmetric(vertical: 16), // Add padding
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Rounded corners
        ), // Text color
      ),
      child: const Text(
        'Update',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Custom text style
      ),
    ),
  ),
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
