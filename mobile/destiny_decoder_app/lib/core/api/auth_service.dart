// Auth service using Firebase Authentication
// Handles signup, login, and token management

import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';


class AuthException implements Exception {
  final String message;
  final String? code;

  AuthException({required this.message, this.code});

  @override
  String toString() => message;
}


class AuthService {
  final FirebaseAuth _firebaseAuth;
  
  final StreamController<bool> _authStateController = StreamController<bool>.broadcast();
  Stream<bool> get authStateStream => _authStateController.stream;

  AuthService({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance {
    // Listen to Firebase auth state changes
    _firebaseAuth.authStateChanges().listen((User? user) {
      _authStateController.add(user != null);
    });
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return _firebaseAuth.currentUser != null;
  }

  // Get current user
  User? get currentUser => _firebaseAuth.currentUser;

  // Get Firebase ID token (for backend API calls)
  Future<String?> getToken() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    return await user.getIdToken();
  }

  // Get user ID
  Future<String?> getUserId() async {
    return _firebaseAuth.currentUser?.uid;
  }

  // Get email
  Future<String?> getEmail() async {
    return _firebaseAuth.currentUser?.email;
  }

  // Get display name (using firstName)
  Future<String?> getDisplayName() async {
    return _firebaseAuth.currentUser?.displayName;
  }

  // Sign up new user
  Future<UserCredential> signup({
    required String email,
    required String password,
    required String firstName,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await userCredential.user?.updateDisplayName(firstName);
      
      _authStateController.add(true);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'weak-password':
          message = 'Password is too weak. Use at least 6 characters.';
          break;
        case 'email-already-in-use':
          message = 'An account already exists with this email.';
          break;
        case 'invalid-email':
          message = 'Invalid email address.';
          break;
        default:
          message = e.message ?? 'Sign up failed. Please try again.';
      }
      throw AuthException(message: message, code: e.code);
    } catch (e) {
      throw AuthException(
        message: 'Network error during sign up: $e',
        code: 'network_error',
      );
    }
  }

  // Login user
  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      _authStateController.add(true);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          message = 'Invalid email or password';
          break;
        case 'user-disabled':
          message = 'This account has been disabled.';
          break;
        case 'too-many-requests':
          message = 'Too many failed attempts. Please try again later.';
          break;
        default:
          message = e.message ?? 'Login failed. Please try again.';
      }
      throw AuthException(message: message, code: e.code);
    } catch (e) {
      throw AuthException(
        message: 'Network error during login: $e',
        code: 'network_error',
      );
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No account found with this email.';
          break;
        case 'invalid-email':
          message = 'Invalid email address.';
          break;
        default:
          message = e.message ?? 'Failed to send reset email.';
      }
      throw AuthException(message: message, code: e.code);
    }
  }

  // Verify token validity
  Future<bool> verifyToken() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return false;
      
      // Reload user to check if still valid
      await user.reload();
      return _firebaseAuth.currentUser != null;
    } catch (e) {
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    await _firebaseAuth.signOut();
    _authStateController.add(false);
  }

  void dispose() {
    _authStateController.close();
  }
}
