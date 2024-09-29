import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _batchNumberController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _stationIdController = TextEditingController();
  final TextEditingController _rankController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isValidName(String name) {
    return name.isNotEmpty && RegExp(r'^[a-zA-Z ]+$').hasMatch(name);
  }

  bool _isValidBatchNumber(String batchNumber) {
    return int.tryParse(batchNumber) != null;
  }

  bool _isValidPhoneNumber(String phoneNumber) {
    return phoneNumber.length == 10 && RegExp(r'^\d{10}$').hasMatch(phoneNumber);
  }

  bool _isValidStationId(String stationId) {
    return int.tryParse(stationId) != null;
  }

  bool _isValidRank(String rank) {
    return rank.isNotEmpty && RegExp(r'^[a-zA-Z ]+$').hasMatch(rank);
  }

  bool _isValidPassword(String password) {
    final RegExp passwordRegExp = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[-_.]).{8,}$');
    return passwordRegExp.hasMatch(password);
  }
Future<void> _register() async {
  if (!_isValidName(_nameController.text.trim())) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Name must contain only alphabets and cannot be empty')),
    );
    return;
  }

  if (!_isValidBatchNumber(_batchNumberController.text.trim())) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Batch number must be a numerical value')),
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

  if (!_isValidPassword(_passwordController.text.trim())) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character (-, _, .)')),
    );
    return;
  }

  if (_passwordController.text.trim() != _confirmPasswordController.text.trim()) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Passwords do not match')),
    );
    return;
  }

  try {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userCredential = await authService.register(
      email: "${_batchNumberController.text}@nyayamitra.com",
      password: _passwordController.text.trim(),
      name: _nameController.text.trim(),
      batchNumber: _batchNumberController.text.trim(),
      phoneNumber: _phoneNumberController.text.trim(),
      stationId: _stationIdController.text.trim(),
      rank: _rankController.text.trim(),
    );

  

    // Save user details to Firestore using UID as the document ID
    await _saveUserToFirestore();

    // Navigate to LoginScreen after successful registration
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Registration failed: $e')),
    );
  }
}


  Future<void> _saveUserToFirestore() async {
  final Map<String, dynamic> userData = {
    'name': _nameController.text.trim(),
    'batchNumber': int.parse(_batchNumberController.text.trim()),
    'phoneNumber': _phoneNumberController.text.trim(),
    'stationId': int.parse(_stationIdController.text.trim()),
    'rank': _rankController.text.trim(),
    'email': "${_batchNumberController.text}@nyayamitra.com",
  };

  try {
    // Use the userId (UID) as the document ID in Firestore
    await FirebaseFirestore.instance.collection('users').get();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User details successfully saved!')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to save user details.')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Display Default Profile Picture
              CircleAvatar(
                radius: 50,
                backgroundImage: const AssetImage('assets/default_profile_icon.png'),
              ),
              const SizedBox(height: 16),
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
                      _buildTextField(_batchNumberController, 'Batch Number', keyboardType: TextInputType.number),
                      _buildTextField(_phoneNumberController, 'Phone Number', keyboardType: TextInputType.phone),
                      _buildTextField(_stationIdController, 'Station ID', keyboardType: TextInputType.number),
                      _buildTextField(_rankController, 'Rank'),
                      _buildTextField(_passwordController, 'Password', obscureText: true),
                      _buildTextField(_confirmPasswordController, 'Confirm Password', obscureText: true),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Register Button
              ElevatedButton(onPressed: _register, child: const Text('Register')),
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
    bool obscureText = false,
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
        obscureText: obscureText,
        keyboardType: keyboardType,
      ),
    );
  }
}
