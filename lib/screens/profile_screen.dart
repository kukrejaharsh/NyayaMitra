import 'dart:io';
import 'package:NyayaMitra/screens/loginSide/profile_photo_preview_screen.dart';
import 'package:NyayaMitra/screens/loginSide/start_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import 'loginSide/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();

  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  // editing controllers
  bool _isEditingName = false;
  bool _isEditingPhone = false;
  bool _isEditingFees = false;
  bool _isEditingSpecialization = false;
  final List<String> _selectedSpecializations = [];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _feesController = TextEditingController();

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

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() => _isLoading = true);
    final userData = await _authService.getUserDetails();
    setState(() {
      _userData = userData;
      _isLoading = false;
      if (userData != null) {
        _nameController.text = userData['name'] ?? "";
        _phoneController.text = userData['phoneNumber'] ?? "";
        if (userData['role'] == "lawyer") {
          _feesController.text = userData['fees']?.toString() ?? "0";
          // ✅ 2. ADDED: Parse the specialization string from DB into the list
          _selectedSpecializations.clear(); // Clear previous state
          final String specializationsStr = userData['specialization'] ?? '';
          if (specializationsStr.isNotEmpty) {
            _selectedSpecializations.addAll(
                specializationsStr.split(',').map((e) => e.trim()).toList());
          }
        }
      }
    });
  }

  /// Validation helpers
  bool _validateName(String name) {
    final regex = RegExp(r'^[a-zA-Z ]+$');
    return regex.hasMatch(name);
  }

  bool _validatePhoneNumber(String phoneNumber) {
    final regex = RegExp(r'^[0-9]{10}$');
    return regex.hasMatch(phoneNumber);
  }

  bool _validateFees(String fees) {
    final regex = RegExp(r'^[0-9]+$');
    return regex.hasMatch(fees);
  }

  /// ✅ 3. NEW: Function to show the specialization picker (similar to RegisterScreen)
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
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: filteredOptions.length,
                          itemBuilder: (context, index) {
                            final specialization = filteredOptions[index];
                            return ListTile(
                              title: Text(specialization),
                              onTap: () {
                                setState(() => _selectedSpecializations
                                    .add(specialization));
                                modalSetState(() =>
                                    availableOptions.remove(specialization));
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

  Future<void> _updateSpecializations() async {
    if (_userData == null) return;
    if (_selectedSpecializations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please select at least one specialization.")),
      );
      return;
    }

    final String newSpecializationString = _selectedSpecializations.join(', ');
    final String oldSpecializationString = _userData!['specialization'] ?? '';

    if (newSpecializationString == oldSpecializationString) return;

    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(_authService.currentUser!.uid)
          .update({'specialization': newSpecializationString});
      await _fetchUserData(); // Refresh data from server
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update: $e")),
        );
      }
    }
  }

  /// 🔹 Logout Confirmation
  Future<void> _confirmLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Logout Confirmation"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel")),
          ElevatedButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Logout")),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.signOut();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  /// 🔹 Delete account with "delete" confirmation
  Future<void> _confirmDeleteAccount() async {
    String input = "";
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Delete Account"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                      "Type 'delete' (all lowercase) to confirm account deletion:"),
                  const SizedBox(height: 10),
                  TextField(
                    onChanged: (val) {
                      setState(() => input = val);
                    },
                    decoration: const InputDecoration(
                      hintText: "delete",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text("Cancel")),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent),
                  onPressed: input == "delete"
                      ? () => Navigator.pop(context, true)
                      : null,
                  child: const Text("Delete Account"),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirm == true) {
      try {
        final user = _authService.currentUser;
        if (user == null) return;

        await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .delete();
        await user.delete();

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const StartScreen()),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error deleting account: $e")),
        );
      }
    }
  }

  /// 🔹 Pick or capture profile photo
  Future<void> _pickProfilePhoto() async {
    final XFile? pickedFile = await showModalBottomSheet<XFile?>(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Choose from Gallery"),
              onTap: () async {
                final img =
                    await _picker.pickImage(source: ImageSource.gallery);
                Navigator.pop(context, img);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Take a Selfie"),
              onTap: () async {
                final img = await _picker.pickImage(source: ImageSource.camera);
                Navigator.pop(context, img);
              },
            ),
          ],
        ),
      ),
    );

    if (pickedFile != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProfilePhotoPreviewScreen(
            imageFile: File(pickedFile.path),
            onConfirm: (file) async {
              await _authService.updateProfilePhoto(file);
              await _fetchUserData();
            },
          ),
        ),
      );
    }
  }

  /// 🔹 Save updated field
  Future<void> _updateField(String key, String newValue) async {
    if (_userData == null || newValue.isEmpty) return;

    if (key == "name" && !_validateName(newValue)) return;
    if (key == "phoneNumber" && !_validatePhoneNumber(newValue)) return;

    final oldValue = _userData![key];
    if (newValue == oldValue) return;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(_authService.currentUser!.uid)
        .update({key: newValue});
    await _fetchUserData();
  }

  /// 🔹 Update fees only for lawyer
  Future<void> _updateFees(String newValue) async {
    if (!_validateFees(newValue)) return;
    final newFees = int.tryParse(newValue) ?? 0;
    try {
      await _authService.updateFees(newFees);
      await _fetchUserData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update fees: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white))
              : _userData == null
                  ? const Center(
                      child: Text("No user data found",
                          style: TextStyle(color: Colors.white, fontSize: 16)))
                  : Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                // Header
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.arrow_back_ios,
                                          color: Colors.white),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                    const Text(
                                      "Profile",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: _fetchUserData,
                                      icon: const Icon(Icons.refresh,
                                          color: Colors.white),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),

                                // Profile Picture
                                GestureDetector(
                                  onTap: _pickProfilePhoto,
                                  child: CircleAvatar(
                                    radius: 65,
                                    backgroundImage: _userData![
                                                'profileImage'] !=
                                            null
                                        ? NetworkImage(
                                            _userData!['profileImage'])
                                        : const AssetImage(
                                                "assets/default_profile_icon.png")
                                            as ImageProvider,
                                    child: Align(
                                      alignment: Alignment.bottomRight,
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.black54,
                                        ),
                                        child: const Icon(Icons.camera_alt,
                                            color: Colors.white, size: 22),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Info Card
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(20),
                                  margin: const EdgeInsets.only(bottom: 20),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: Colors.white24, width: 1),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildEditableField(
                                          "Name", "name", _nameController,
                                          isEditing: _isEditingName,
                                          onEditToggle: () {
                                        setState(() =>
                                            _isEditingName = !_isEditingName);
                                      }),
                                      const Divider(color: Colors.white30),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: RichText(
                                              text: TextSpan(
                                                style: const TextStyle(
                                                    fontSize: 18,
                                                    fontFamily: 'Roboto'),
                                                children: [
                                                  TextSpan(
                                                    text: "Email: ",
                                                    style: TextStyle(
                                                      color:
                                                          Colors.blueGrey[200],
                                                      fontWeight:
                                                          FontWeight.w800,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: _userData!['email'] ??
                                                        'Not provided',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          _authService
                                                  .currentUser!.emailVerified
                                              ? const Icon(Icons.verified,
                                                  color: Colors.greenAccent,
                                                  size: 20)
                                              : TextButton(
                                                  onPressed: () async {
                                                    await _authService
                                                        .sendVerificationEmail(
                                                            _authService
                                                                .currentUser!);
                                                  },
                                                  child: const Text("Verify",
                                                      style: TextStyle(
                                                          color:
                                                              Colors.redAccent,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ),
                                        ],
                                      ),
                                      const Divider(color: Colors.white30),
                                      _buildEditableField("Phone Number",
                                          "phoneNumber", _phoneController,
                                          isEditing: _isEditingPhone,
                                          onEditToggle: () {
                                        setState(() =>
                                            _isEditingPhone = !_isEditingPhone);
                                      }),
                                      const Divider(color: Colors.white30),
                                      const SizedBox(height: 10),
                                      RichText(
                                        text: TextSpan(
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontFamily: 'Roboto'),
                                          children: [
                                            TextSpan(
                                              text: "Role: ",
                                              style: TextStyle(
                                                color: Colors.blueGrey[200],
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            TextSpan(
                                              text: _userData!['role'] ?? 'N/A',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      const Divider(color: Colors.white30),
                                      if (_userData!['role'] == "lawyer") ...[
                                        const Divider(color: Colors.white30),
                                        _buildEditableField(
                                            "Fees", "fees", _feesController,
                                            isEditing: _isEditingFees,
                                            onEditToggle: () => setState(() =>
                                                _isEditingFees =
                                                    !_isEditingFees)),
                                        const Divider(color: Colors.white30),
                                        _buildEditableSpecializationField(),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // ✅ Fixed Action Buttons at Bottom
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildGradientButton(
                                text: "Logout",
                                icon: Icons.logout,
                                colors: const [
                                  Color(0xFFFF416C),
                                  Color(0xFFFF4B2B)
                                ],
                                onTap: _confirmLogout,
                              ),
                              _buildGradientButton(
                                text: "Delete",
                                icon: Icons.delete_forever,
                                colors: const [
                                  Color(0xFF141E30),
                                  Color(0xFF243B55)
                                ],
                                onTap: _confirmDeleteAccount,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }

  Widget _buildEditableSpecializationField() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 18, fontFamily: 'Roboto'),
                    children: [
                      TextSpan(
                        text: "Specialization: ",
                        style: TextStyle(
                          color: Colors.blueGrey[200],
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: _selectedSpecializations.map((spec) {
                    return Chip(
                      label: Text(spec,
                          style: const TextStyle(color: Colors.white)),
                      backgroundColor: const Color(0xFF6C63FF).withOpacity(0.8),
                      onDeleted: _isEditingSpecialization
                          ? () {
                              setState(
                                  () => _selectedSpecializations.remove(spec));
                            }
                          : null,
                      deleteIcon: _isEditingSpecialization
                          ? const Icon(Icons.close,
                              size: 18, color: Colors.white)
                          : null,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        IconButton(
          icon: Icon(
            _isEditingSpecialization ? Icons.check_circle : Icons.edit,
            color:
                _isEditingSpecialization ? Colors.greenAccent : Colors.white70,
            size: 22,
          ),
          onPressed: () {
            if (_isEditingSpecialization) {
              // Save changes
              _updateSpecializations();
            } else {
              // Open picker
              _showSpecializationPicker();
            }
            setState(
                () => _isEditingSpecialization = !_isEditingSpecialization);
          },
        ),
      ],
    );
  }

  /// Editable Profile Field with validation + ❌ reset
  Widget _buildEditableField(
    String title,
    String key,
    TextEditingController controller, {
    required bool isEditing,
    required VoidCallback onEditToggle,
  }) {
    // --- This validation logic is part of your original code ---
    bool isValid = true;
    if (isEditing) {
      if (key == "name") {
        isValid = _validateName(controller.text);
      } else if (key == "phoneNumber") {
        isValid = _validatePhoneNumber(controller.text);
      } else if (key == "fees") {
        isValid = _validateFees(controller.text);
      }
    }
    // --- End of validation logic ---

    return Row(
      children: [
        Expanded(
          child: isEditing
              ? TextField(
                  controller: controller,
                  maxLength: key == "phoneNumber" ? 10 : null,
                  keyboardType: key == "phoneNumber" || key == "fees"
                      ? TextInputType.number
                      : TextInputType.text,
                  inputFormatters: key == "phoneNumber" || key == "fees"
                      ? [FilteringTextInputFormatter.digitsOnly]
                      // Allow letters, spaces, and common name characters like '-'
                      : [
                          FilteringTextInputFormatter.allow(
                              RegExp(r"[a-zA-Z\s-]"))
                        ],
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    counterText: "",
                    labelText: title,
                    labelStyle: const TextStyle(color: Colors.white70),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white38),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: isValid ? Colors.white : Colors.redAccent,
                      ),
                    ),
                  ),
                  // PRO-TIP: Use onChanged for real-time validation
                  onChanged: (value) {
                    setState(
                        () {}); // Re-run the build to update the isValid flag
                  },
                )
              // ✅ REPLACED Text with RichText for multi-style display
              : RichText(
                  text: TextSpan(
                    // Default style for all text spans
                    style: const TextStyle(
                      fontSize: 18,
                      fontFamily: 'Roboto', // Ensure consistent font
                    ),
                    children: [
                      // TextSpan for the KEY (e.g., "Name: ")
                      TextSpan(
                        text: "$title: ",
                        style: TextStyle(
                          color: Colors
                              .blueGrey[200], // Highlight color for the key
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      // TextSpan for the VALUE (e.g., "Revant")
                      TextSpan(
                        text: controller.text,
                        style: const TextStyle(
                          color: Colors.white, // White color for the value
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
        IconButton(
          icon: Icon(
            isEditing
                ? (isValid ? Icons.check_circle : Icons.cancel)
                : Icons.edit,
            color: isEditing
                ? (isValid ? Colors.greenAccent : Colors.redAccent)
                : Colors.white70,
            size: 22,
          ),
          onPressed: () {
            if (!isEditing) {
              onEditToggle();
              return;
            }

            if (isValid) {
              // Note: _userData needs to be available in your State class
              if (controller.text != _userData![key].toString()) {
                _updateField(key, controller.text);
              }
              onEditToggle();
            } else {
              // Reset to original value if invalid
              controller.text = _userData![key]?.toString() ?? "";
              onEditToggle();
            }
          },
        ),
      ],
    );
  }

  /// Gradient Button
  Widget _buildGradientButton({
    required String text,
    required IconData icon,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: colors.last.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.white),
            const SizedBox(width: 6),
            Text(text,
                style: const TextStyle(fontSize: 15, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
