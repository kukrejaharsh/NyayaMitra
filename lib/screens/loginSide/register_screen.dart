import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // --- Controllers ---
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _feesController = TextEditingController();

  // --- State Variables ---
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  String _selectedRole = "client";
  final List<String> _selectedSpecializations = [];

  // --- Error States ---
  String? _nameError;
  String? _emailError;
  String? _phoneError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _feesError;
  String? _specializationError;

  final List<String> _allSpecializations = const [
    'Civil Law',
    'Criminal Law',
    'Corporate Law',
    'Tax Law',
    'Intellectual Property Law',
    'Family Law',
    'Labour & Employment Law',
    'Constitutional Law',
    'Real Estate Law',
    'Cyber Law',
    'Environmental Law',
    'Banking & Finance Law',
    'International Law',
  ];

  /// --- Validators ---
  bool _isValidName(String name) =>
      name.isNotEmpty && RegExp(r'^[a-zA-Z ]+$').hasMatch(name);
  bool _isValidEmail(String email) =>
      RegExp(r'^[a-z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$').hasMatch(email);
  bool _isValidPhone(String phone) =>
      phone.isEmpty ||
      (phone.length == 10 && RegExp(r'^\d{10}$').hasMatch(phone));
  bool _isValidPassword(String password) =>
      RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[-_.]).{8,}$')
          .hasMatch(password);
  bool _isValidSpecialization() => _selectedSpecializations.isNotEmpty;

  /// --- Image Picker ---
  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black.withOpacity(0.4),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo, color: Colors.white),
              title: const Text("Choose from Gallery",
                  style: TextStyle(color: Colors.white)),
              onTap: () async {
                final pickedFile = await _picker.pickImage(
                    source: ImageSource.gallery, imageQuality: 70);
                if (pickedFile != null) {
                  setState(() => _profileImage = File(pickedFile.path));
                }
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.white),
              title: const Text("Take a Photo",
                  style: TextStyle(color: Colors.white)),
              onTap: () async {
                final pickedFile = await _picker.pickImage(
                    source: ImageSource.camera, imageQuality: 70);
                if (pickedFile != null) {
                  setState(() => _profileImage = File(pickedFile.path));
                }
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// --- Specialization Picker ---
  Future<void> _showSpecializationPicker() async {
    final searchController = TextEditingController();

    List<String> availableOptions = _allSpecializations
        .where((spec) => !_selectedSpecializations.contains(spec))
        .toList();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter modalSetState) {
            final filteredOptions = availableOptions
                .where((spec) => spec
                    .toLowerCase()
                    .contains(searchController.text.toLowerCase()))
                .toList();

            return DraggableScrollableSheet(
              initialChildSize: 0.8,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: TextField(
                          controller: searchController,
                          autofocus: true,
                          decoration: InputDecoration(
                            labelText: 'Search Specialization',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          onChanged: (value) => modalSetState(() {}),
                        ),
                      ),
                      // ✅ NEW: Show selected items at the top of the picker
                      if (_selectedSpecializations.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Selected (${_selectedSpecializations.length})",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[600]),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Wrap(
                            spacing: 8.0,
                            runSpacing: 4.0,
                            children: _selectedSpecializations.map((spec) {
                              return Chip(
                                label: Text(spec),
                                onDeleted: () {
                                  // Remove from main list
                                  setState(() =>
                                      _selectedSpecializations.remove(spec));
                                  // Add back to available options and refresh modal UI
                                  modalSetState(() {
                                    availableOptions.add(spec);
                                    availableOptions.sort(); // Keep it sorted
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ),
                        const Divider(height: 16, indent: 16, endIndent: 16),
                      ],
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: filteredOptions.length,
                          itemBuilder: (context, index) {
                            final specialization = filteredOptions[index];
                            return ListTile(
                              title: Text(specialization),
                              onTap: () {
                                setState(() {
                                  _selectedSpecializations.add(specialization);
                                  _specializationError = null;
                                });
                                modalSetState(() {
                                  availableOptions.remove(specialization);
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  /// --- Form Validation & Submission ---
  bool _validateAll() {
    setState(() {
      _nameError = _isValidName(_nameController.text.trim())
          ? null
          : "Only alphabets allowed";
      _emailError = _isValidEmail(_emailController.text.trim())
          ? null
          : "Enter a valid email";
      _phoneError = _isValidPhone(_phoneController.text.trim())
          ? null
          : "Phone number must be 10 digits";
      _passwordError = _isValidPassword(_passwordController.text.trim())
          ? null
          : "Must contain uppercase, lowercase, number & special char";
      _confirmPasswordError = _passwordController.text.trim() ==
              _confirmPasswordController.text.trim()
          ? null
          : "Passwords do not match";

      if (_selectedRole == "lawyer") {
        _feesError = (_feesController.text.trim().isEmpty ||
                double.tryParse(_feesController.text.trim()) == null)
            ? "Enter valid fees"
            : null;
        _specializationError = _isValidSpecialization()
            ? null
            : "Please select at least one specialization";
      } else {
        _feesError = null;
        _specializationError = null;
      }
    });
    return _nameError == null &&
        _emailError == null &&
        _phoneError == null &&
        _passwordError == null &&
        _confirmPasswordError == null &&
        _feesError == null &&
        _specializationError == null;
  }

  Future<void> _register() async {
    if (!_validateAll()) return;

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        password: _passwordController.text.trim(),
        role: _selectedRole,
        profileImage: _profileImage,
        fees: _selectedRole == "lawyer"
            ? int.parse(_feesController.text.trim())
            : null,
        specialization:
            _selectedRole == "lawyer" && _selectedSpecializations.isNotEmpty
                ? _selectedSpecializations.join(', ')
                : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Registration successful! Please login.')));
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    } catch (e) {
      _showError('Registration failed: $e');
    }
  }

  void _showError(String msg) {
    if (mounted)
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [
              Color(0xFF6C63FF),
              Color.fromARGB(255, 4, 129, 167)
            ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : null,
                      child: _profileImage == null
                          ? const Icon(Icons.camera_alt,
                              size: 40, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text("Create Account",
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 30),

                  // Text Fields
                  _buildValidatedField(
                      controller: _nameController,
                      icon: Icons.person,
                      hint: "Full Name",
                      errorText: _nameError,
                      validator: (val) => setState(() => _nameError =
                          _isValidName(val) ? null : "Only alphabets allowed")),
                  _buildValidatedField(
                      controller: _emailController,
                      icon: Icons.email,
                      hint: "Email Address",
                      keyboardType: TextInputType.emailAddress,
                      errorText: _emailError,
                      validator: (val) => setState(() => _emailError =
                          _isValidEmail(val) ? null : "Enter a valid email")),
                  _buildValidatedField(
                      controller: _phoneController,
                      icon: Icons.phone,
                      hint: "Phone Number",
                      keyboardType: TextInputType.phone,
                      errorText: _phoneError,
                      validator: (val) => setState(() => _phoneError =
                          _isValidPhone(val)
                              ? null
                              : "Phone number must be 10 digits")),
                  _buildValidatedField(
                      controller: _passwordController,
                      icon: Icons.lock,
                      hint: "Password",
                      obscureText: true,
                      errorText: _passwordError,
                      validator: (val) => setState(() => _passwordError =
                          _isValidPassword(val)
                              ? null
                              : "Must contain uppercase, lowercase, number & special char")),
                  _buildValidatedField(
                      controller: _confirmPasswordController,
                      icon: Icons.lock,
                      hint: "Confirm Password",
                      obscureText: true,
                      errorText: _confirmPasswordError,
                      validator: (val) => setState(() => _confirmPasswordError =
                          val == _passwordController.text.trim()
                              ? null
                              : "Passwords do not match")),
                  const SizedBox(height: 15),

                  // Role Dropdown
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.5))),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedRole,
                        isExpanded: true,
                        dropdownColor: Colors.black87,
                        icon: const Icon(Icons.arrow_drop_down,
                            color: Colors.white),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                        onChanged: (value) =>
                            setState(() => _selectedRole = value!),
                        items: const [
                          DropdownMenuItem(
                              value: "client",
                              child: Row(children: [
                                Text("👤 ",
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                        height: 1.2)),
                                Text("Client",
                                    style: TextStyle(color: Colors.white))
                              ])),
                          DropdownMenuItem(
                              value: "lawyer",
                              child: Row(children: [
                                Text("⚖️ ",
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                        height: 1.2)),
                                Text("Lawyer",
                                    style: TextStyle(color: Colors.white))
                              ])),
                        ],
                      ),
                    ),
                  ),

                  // Lawyer-specific fields
                  if (_selectedRole == "lawyer")
                    _buildValidatedField(
                        controller: _feesController,
                        icon: Icons.attach_money,
                        hint: "Fees per hearing",
                        keyboardType: TextInputType.number,
                        errorText: _feesError,
                        validator: (val) => setState(() => _feesError =
                            (val.isEmpty || double.tryParse(val) == null)
                                ? "Enter valid fees"
                                : null)),
                  if (_selectedRole == "lawyer") _buildSpecializationField(),

                  const SizedBox(height: 25),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 14)),
                    onPressed: _register,
                    child: const Text("Register",
                        style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF003366),
                            fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => const LoginScreen())),
                    child: const Text("Already have an account? Login",
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// --- Helper Widgets ---

  Widget _buildSpecializationField() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: _showSpecializationPicker,
            child: InputDecorator(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.work_outline, color: Colors.white),
                // ✅ HINT FIX: The `child` property now handles the visual state
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.white.withOpacity(0.5))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Colors.white, width: 1.5)),
              ),
              // ✅ HINT FIX: Conditionally show a Text widget or the Chips
              child: _selectedSpecializations.isEmpty
                  ? Text("Select Specialization(s)",
                      style: TextStyle(color: Colors.white.withOpacity(0.7),
                          fontWeight: FontWeight.w400))
                  : Wrap(
                      spacing: 6.0,
                      runSpacing: 4.0,
                      children: _selectedSpecializations.map((spec) {
                        return Chip(
                          label: Text(spec,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12)),
                          backgroundColor:
                              const Color(0xFF6C63FF).withOpacity(0.8),
                          onDeleted: () => setState(
                              () => _selectedSpecializations.remove(spec)),
                          deleteIcon: const Icon(Icons.close,
                              size: 16, color: Colors.white),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 2),
                        );
                      }).toList(),
                    ),
            ),
          ),
          if (_specializationError != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 12),
              child: Text(_specializationError!,
                  style:
                      const TextStyle(color: Colors.redAccent, fontSize: 13)),
            ),
        ],
      ),
    );
  }

  Widget _buildValidatedField(
      {required TextEditingController controller,
      required IconData icon,
      required String hint,
      String? errorText,
      required Function(String) validator,
      bool obscureText = false,
      TextInputType keyboardType = TextInputType.text}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: const TextStyle(color: Colors.white),
            onChanged: validator,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.white),
              hintText: hint,
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
              filled: true,
              fillColor: Colors.white.withOpacity(0.2),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.5))),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Colors.white, width: 1.5)),
            ),
          ),
          if (errorText != null)
            Padding(
                padding: const EdgeInsets.only(top: 4, left: 12),
                child: Text(errorText,
                    style: const TextStyle(
                        color: Colors.redAccent, fontSize: 13))),
        ],
      ),
    );
  }
}
