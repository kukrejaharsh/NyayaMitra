import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart'; // Import your AuthService
import 'dashboard_screen.dart'; // Import your DashboardScreen
import 'register_screen.dart'; // Import your RegisterScreen

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController(); // Email Controller
  final TextEditingController _passwordController = TextEditingController(); // Password Controller
  String _errorMessage = ""; // Variable to store error messages

  void _login() async {
    final authService = Provider.of<AuthService>(context, listen: false);

    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    // Check if email and password are provided
    if (email.isEmpty) {
      setState(() {
        _errorMessage = "Please enter your email.";
      });
      return;
    }

    if (password.isEmpty) {
      setState(() {
        _errorMessage = "Please enter your password.";
      });
      return;
    }

    // Perform login with Firebase Authentication
    try {
      await authService.login(email: email, password: password);

      // If login is successful, navigate to DashboardScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } catch (e) {
      // Handle login errors
      setState(() {
        if (e.toString().contains("wrong-password")) {
          _errorMessage = "Incorrect password. Please try again.";
        } else if (e.toString().contains("user-not-found")) {
          _errorMessage = "No user found with this email.";
        } else if (e.toString().contains("invalid-email")) {
          _errorMessage = "Invalid email format.";
        } else {
          _errorMessage = "Login Failed. Please check your email and password.";
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login',
        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 227, 227, 247),
                          ),
        ),
        backgroundColor: const Color.fromARGB(255, 0, 51, 102),),
      body: Center(
        child: Column(
          children: [
            // Lion logo enclosed in a blue box
            Container(
              color: const Color.fromARGB(255, 9, 74, 153), // Set the background color to blue
              padding: const EdgeInsets.all(10), // Add padding for aesthetics
              width: double.infinity, // Make it full width
              child: Center(
                child: Image.asset(
                  'assets/lion_logo.png',
                  height: 80, // Adjust the height as needed
                  fit: BoxFit.contain,
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(10), // Add padding for aesthetics
              child: Center(
                child: Image.asset(
                  'assets/law_logo.png',
                  height: 80, // Adjust the height as needed
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const Text(
              'NyayaMitra',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 87, 77, 77),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Email Input Field
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          hintText: 'BatchNumber@nyayamitra.com',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(10),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Password Input Field
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter Your Password',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(10),
                        ),
                        obscureText: true,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Display Error Message
                    if (_errorMessage.isNotEmpty) ...[
                      Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 10),
                    ],
                    // Login Button
                    ElevatedButton.icon(
                      onPressed: _login,
                      icon: const Icon(Icons.login), // Add an icon to the button
                      label: const Text(
                        'Login',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Improve text style
                      ),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, 
                        backgroundColor: Colors.blueAccent, // Set text color
                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20), // Add padding
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30), // Round the corners
                        ),
                        elevation: 5, // Add shadow
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Register Button with improved UI
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RegisterScreen()),
                        );
                      },
                      icon: const Icon(Icons.app_registration), // Add an icon to the button
                      label: const Text(
                        'Register',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Improve text style
                      ),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color.fromARGB(255, 6, 171, 200), // Set text color
                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20), // Add padding
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30), // Round the corners
                        ),
                        elevation: 5, // Add shadow
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
