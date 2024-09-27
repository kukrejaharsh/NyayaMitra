// lib/models/user.dart

class User {
  final String uid;          // Unique user ID
  final String name;        // User's name
  final String email;       // User's email
  final String phoneNumber; // User's phone number (optional)

  User({
    required this.uid,
    required this.name,
    required this.email,
    this.phoneNumber = '',
  });

  // Method to create a User object from a map (e.g., from Firestore)
  factory User.fromMap(Map<String, dynamic> data) {
    return User(
      uid: data['uid'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
    );
  }

  // Method to convert a User object to a map (for saving to Firestore)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
    };
  }
}
