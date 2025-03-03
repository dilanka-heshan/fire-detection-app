import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'database_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseService _db = DatabaseService();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update last login timestamp
      await _db.updateUserProfile({
        'lastLogin': FieldValue.serverTimestamp(),
      });

      return credential;
    } catch (e) {
      debugPrint('Sign in error: $e');
      throw _handleAuthException(e);
    }
  }

  // Register with email and password
  Future<UserCredential> registerWithEmailAndPassword(
      String email, String password, String name) async {
    try {
      debugPrint('Starting registration process...');

      // Create auth user
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw FirebaseAuthException(
          code: 'null-user',
          message: 'Failed to create user account.',
        );
      }

      debugPrint('Auth user created successfully');

      try {
        // Update display name first
        await credential.user!.updateDisplayName(name);
        debugPrint('Display name updated');

        // Create user profile in Firestore
        await _db.createUserProfile(credential.user!, name);
        debugPrint('User profile created in Firestore');

        // Wait for a short time to ensure Firestore has processed the write
        await Future.delayed(const Duration(milliseconds: 1000));

        // Reload the user to get updated profile
        await credential.user!.reload();
        debugPrint('User profile reloaded');

        // Verify that the profile was created
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(credential.user!.uid)
            .get();

        if (!userDoc.exists) {
          throw FirebaseAuthException(
            code: 'profile-creation-failed',
            message: 'User profile was not created properly.',
          );
        }

        debugPrint('Registration process completed successfully');
        return credential;
      } catch (e) {
        // If profile creation fails, delete the auth user
        debugPrint('Error during profile creation: $e');
        await credential.user?.delete();
        throw FirebaseAuthException(
          code: 'profile-creation-failed',
          message: 'Failed to create user profile. Please try again.',
        );
      }
    } catch (e) {
      debugPrint('Registration error: $e');
      throw _handleAuthException(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('Sign out error: $e');
      throw _handleAuthException(e);
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      debugPrint('Password reset error: $e');
      throw _handleAuthException(e);
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return 'No user found with this email.';
        case 'wrong-password':
          return 'Wrong password provided.';
        case 'email-already-in-use':
          return 'Email is already in use.';
        case 'invalid-email':
          return 'Invalid email address.';
        case 'weak-password':
          return 'Password is too weak.';
        case 'profile-creation-failed':
          return 'Failed to create user profile. Please try again.';
        case 'null-user':
          return 'Failed to create user account.';
        case 'network-request-failed':
          return 'Network error. Please check your internet connection.';
        case 'operation-not-allowed':
          return 'Email/password accounts are not enabled. Please contact support.';
        default:
          return 'Authentication failed: ${e.message ?? 'Please try again.'}';
      }
    }
    return 'An error occurred. Please try again.';
  }
}
