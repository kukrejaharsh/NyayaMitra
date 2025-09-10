import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:NyayaMitra/screens/loginSide/register_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = "";

  Future<void> _resetPassword() async {
    String email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() => _errorMessage = "Email is required.");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("📧 Password reset link sent! Check your email."),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // go back to login
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == "user-not-found") {
          _errorMessage =
              "❌ This email is not registered. Please create an account.";
        } else if (e.code == "invalid-email") {
          _errorMessage = "⚠️ Please enter a valid email address.";
        } else {
          _errorMessage = e.message ?? "Something went wrong.";
        }
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// 🔹 Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6C63FF), Color.fromARGB(255, 4, 129, 167)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          /// 🔹 Forgot Password Form
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo
                  Image.asset("assets/law_logo_new.png", height: 120),
                  const SizedBox(height: 10),
                  const Text(
                    "NyayaMitra",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Screen Title
                  const Text(
                    "Reset Password",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Email Field
                  _buildTextField(
                    _emailController,
                    Icons.email,
                    "Enter your registered Email",
                    keyboardType: TextInputType.emailAddress,
                  ),

                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Reset Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 14),
                    ),
                    onPressed: _isLoading ? null : _resetPassword,
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: Color(0xFF003366), strokeWidth: 2)
                        : const Text(
                            "Send Reset Link",
                            style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFF003366),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),

                  const SizedBox(height: 15),

                  // Back to login
                  TextButton(
                    onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const RegisterScreen()),
                        );
                      },
                    child: const Text(
                      "Create new Account? Register",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 Common styled input (same as login)
  Widget _buildTextField(
    TextEditingController controller,
    IconData icon,
    String hint, {
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
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
            borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white, width: 1.5),
          ),
        ),
      ),
    );
  }
}
