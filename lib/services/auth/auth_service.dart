import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_chat_app/models/user_model.dart';

class AuthService {
  // Instance of FirebaseAuth
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Ambil data user dari Firestore berdasarkan email
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userData = querySnapshot.docs.first.data();
        final userModel = UserModel.fromMap(userData);

        // Simpan semua data ke SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('uid', userModel.uid);
        await prefs.setString('name', userModel.name);
        await prefs.setString('email', userModel.email);
        await prefs.setString(
          'createdAt',
          userModel.createdAt?.toIso8601String() ?? '',
        );
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception('Failed to sign in: ${e.code} - ${e.message}');
    }
  }

  // Sign Up
  Future<UserCredential?> signUpWithEmailAndPassword(
    String name,
    String email,
    String password,
  ) async {
    try {
      // Check if user already exists
      // Cek apakah email sudah terdaftar
      // Cek apakah email sudah terdaftar di Firestore
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        throw Exception('Email sudah terdaftar');
      }

      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Simpan data user ke Firestore
      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'name': name,
        'uid': userCredential.user?.uid,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        // Tambahkan field lain jika perlu
      });
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception('Failed to sign up: ${e.code} - ${e.message}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  // Error handling

  Future<UserModel?> getLocalUser() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('uid') ?? '';
    final name = prefs.getString('name') ?? '';
    final email = prefs.getString('email') ?? '';
    final createdAtStr = prefs.getString('createdAt');
    DateTime? createdAt = createdAtStr != null && createdAtStr.isNotEmpty
        ? DateTime.parse(createdAtStr)
        : null;

    if (uid.isEmpty || name.isEmpty || email.isEmpty) return null;

    return UserModel(uid: uid, name: name, email: email, createdAt: createdAt);
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
