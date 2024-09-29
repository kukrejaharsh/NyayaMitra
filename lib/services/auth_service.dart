import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register a new user
  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String batchNumber,
    required String phoneNumber,
    required String stationId,
    required String rank,
  }) async {
    try {
      // Create user in Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save additional user details in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'batchNumber': batchNumber,
        'phoneNumber': phoneNumber,
        'stationId': stationId,
        'rank': rank,
        'email': email,
      });
    } catch (e) {
      throw Exception('Failed to register user: $e');
    }
  }

  // Login existing user
  Future<void> login({required String email, required String password}) async {
    try {
      // Authenticate using Firebase Authentication
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if user details exist in Firestore
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
      if (!userDoc.exists) {
        throw Exception('User details not found in Firestore');
      }
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  // Sign out user
  Future<void> signOut() async {
    try {
      await _auth.signOut();  // Sign out from Firebase Authentication
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }
}
