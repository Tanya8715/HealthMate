import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'dart:convert';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Sign Up with Email & Password
  Future<User?> signUpWithEmailPassword(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      rethrow;
    }
  }

  /// Sign In with Email & Password
  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      rethrow;
    }
  }

  /// Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Get Current User
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// Send OTP to Email via EmailJS
  Future<void> sendOtpToEmail(String email) async {
    try {
      final otp = (100000 + Random().nextInt(900000)).toString();
      final expiresAt =
          DateTime.now().add(Duration(minutes: 5)).millisecondsSinceEpoch;

      // Store OTP with expiry in Firestore
      await _firestore.collection('emailOtps').doc(email).set({
        'otp': otp,
        'expiresAt': expiresAt,
      });

      // Send OTP using EmailJS API
      final response = await http.post(
        Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
        headers: {
          'origin': 'http://localhost',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "service_id":
              "service_t16wq0e", // <-- Replace with your EmailJS service ID
          "template_id":
              "template_rd8a1dg", // <-- Replace with your EmailJS template ID
          "user_id":
              "pRIA_V-9pPb18XZLp", // <-- Replace with your EmailJS user ID
          "template_params": {"user_email": email, "user_otp": otp},
        }),
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to send OTP email");
      }
    } catch (e) {
      print("❌ sendOtpToEmail failed: $e");
      rethrow;
    }
  }

  /// Verify OTP
  Future<bool> verifyOtp(String email, String enteredOtp) async {
    try {
      final doc = await _firestore.collection('emailOtps').doc(email).get();

      if (!doc.exists) {
        print("❌ No OTP found for this email");
        return false;
      }

      final data = doc.data()!;
      final storedOtp = data['otp'];
      final expiresAt = data['expiresAt'];

      final now = DateTime.now().millisecondsSinceEpoch;

      if (now > expiresAt) {
        print("❌ OTP expired");
        return false;
      }

      if (enteredOtp != storedOtp) {
        print("❌ OTP does not match");
        return false;
      }

      // OTP is valid, optionally delete it
      await _firestore.collection('emailOtps').doc(email).delete();

      return true;
    } catch (e) {
      print("❌ verifyOtp failed: $e");
      return false;
    }
  }
}
