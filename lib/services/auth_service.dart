import 'dart:io';
import 'package:NyayaMitra/models/user_model';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// 🔹 Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// 🔹 Current Firebase user
  User? get currentUser => _auth.currentUser;

  /// 🔹 Register a new user/lawyer (with rollback if Firestore fails)
  Future<User?> register({
    required String email,
    required String password,
    required String name,
    required String role, // "client" | "lawyer" | "admin"
    String? phoneNumber,
    File? profileImage,
    int? fees, // only required for lawyer
    String? specialization, // ✅ ADDED: Specialization parameter for lawyers
  }) async {
    UserCredential? userCred;

    try {
      // 1. Create Firebase user
      userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = userCred.user!.uid;

      // 2. Upload profile photo if provided
      String? photoUrl;
      if (profileImage != null) {
        final ref = _storage.ref().child("profile_photos/$uid.jpg");
        await ref.putFile(profileImage);
        photoUrl = await ref.getDownloadURL();
      }

      // 3. Build UserModel
      final userModel = UserModel(
        userId: uid,
        name: name,
        email: email,
        phone: phoneNumber ?? "",
        role: role,
        profileImage: photoUrl,
        createdAt: DateTime.now(),
        // ✅ ADDED: Pass specialization to the model if the role is 'lawyer'
        specialization: role == "lawyer" ? specialization : null,
        totalCases: 0,
        activeCases: 0,
        casesWon: 0,
        fees: role == "lawyer" ? ((fees ?? 0).toDouble()) : 0.0,
        rating: 0.0,
        ratingsCount: 0,
      );

      // 4. Save to Firestore
      await _firestore.collection('users').doc(uid).set(userModel.toMap());

      // 5. Send verification email
      await sendVerificationEmail(userCred.user!);

      return userCred.user;
    } catch (e) {
      if (userCred != null) {
        await userCred.user?.delete();
      }
      throw Exception("Registration failed: $e");
    }
  }

  /// 🔹 Send email verification
  Future<void> sendVerificationEmail(User user) async {
    if (!user.emailVerified) {
      try {
        await user.sendEmailVerification();
      } catch (e) {
        throw Exception("Failed to send verification email: $e");
      }
    }
  }

  /// 🔹 Login
  Future<User?> login({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Ensure Firestore profile exists
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(userCred.user!.uid).get();

      if (!doc.exists) {
        throw Exception("User profile missing in Firestore");
      }

      return userCred.user;
    } catch (e) {
      throw Exception("Login failed: $e");
    }
  }

  /// 🔹 Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// 🔹 Get Firestore user profile
  Future<Map<String, dynamic>?> getUserDetails() async {
    if (currentUser == null) return null;
    final doc =
        await _firestore.collection('users').doc(currentUser!.uid).get();
    return doc.data() as Map<String, dynamic>?;
  }

  /// 🔹 Update profile photo
  Future<void> updateProfilePhoto(File newImage) async {
    if (currentUser == null) throw Exception("No user logged in");

    final uid = currentUser!.uid;
    final ref = _storage.ref().child("profile_photos/$uid.jpg");
    await ref.putFile(newImage);
    final photoUrl = await ref.getDownloadURL();

    await _firestore.collection('users').doc(uid).update({
      'profileImage': photoUrl,
    });
  }

  /// 🔹 Update lawyer fees (only for lawyer role)
  Future<void> updateFees(int newFees) async {
    if (currentUser == null) throw Exception("No user logged in");

    final uid = currentUser!.uid;
    final userDoc = await _firestore.collection('users').doc(uid).get();

    if (userDoc.exists && userDoc["role"] == "lawyer") {
      await _firestore.collection('users').doc(uid).update({
        'fees': newFees,
      });
    } else {
      throw Exception("Only lawyers can update fees");
    }
  }
}
