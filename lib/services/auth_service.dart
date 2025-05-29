import 'package:firebase_auth/firebase_auth.dart'
    as fb_auth; // Aliased to avoid name clash
import 'package:flutter/material.dart'; // For debugPrint, not strictly needed for the service itself

class User {
  final String uid;
  final String? displayName;
  final String? email;
  final String? photoURL;
  final bool isEmailVerified;

  User({
    required this.uid,
    this.displayName,
    this.email,
    this.photoURL,
    required this.isEmailVerified,
  });

  // Factory constructor to create a User from Firebase User
  factory User.fromFirebaseUser(fb_auth.User firebaseUser) {
    return User(
      uid: firebaseUser.uid,
      displayName: firebaseUser.displayName,
      email: firebaseUser.email,
      photoURL: firebaseUser.photoURL,
      isEmailVerified: firebaseUser.emailVerified,
    );
  }

  // You can add other methods like toJson, fromJson if needed for database interaction
}

// --- Authentication Service using Firebase Auth ---
class AuthService {
  final fb_auth.FirebaseAuth _firebaseAuth = fb_auth.FirebaseAuth.instance;

  // --- Stream to listen to Authentication State Changes ---
  // This is the primary way to know if a user is logged in or out.
  // It emits a Firebase User object when the auth state changes.
  Stream<User?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      if (firebaseUser == null) {
        return null;
      }
      // Convert Firebase User to your custom User model
      return User.fromFirebaseUser(firebaseUser);
    });
  }

  // --- Get Current User ---
  // Provides synchronous access to the current user, if one exists.
  // It's often better to rely on the authStateChanges stream for UI updates.
  User? get currentUser {
    final fbUser = _firebaseAuth.currentUser;
    if (fbUser == null) {
      return null;
    }
    return User.fromFirebaseUser(fbUser);
  }

  // --- Sign Up with Email and Password ---
  Future<User?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName, // Optional: for setting display name during sign up
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        if (displayName != null && displayName.isNotEmpty) {
          await userCredential.user!.updateDisplayName(displayName);
          // Reload the user to get the updated display name
          await userCredential.user!.reload();
        }
        // It's good practice to re-fetch the user or use the one from userCredential
        // to ensure all properties (like an updated displayName) are fresh.
        final freshFirebaseUser = _firebaseAuth.currentUser;
        if (freshFirebaseUser != null) {
          return User.fromFirebaseUser(freshFirebaseUser);
        }
      }
      return null;
    } on fb_auth.FirebaseAuthException catch (e) {
      debugPrint(
        "Firebase Auth Exception during sign up: ${e.message} (Code: ${e.code})",
      );
      // You can throw a custom exception or return null/handle specific error codes
      // e.g., if (e.code == 'email-already-in-use') { ... }
      rethrow; // Rethrow to be caught by the UI layer
    } catch (e) {
      debugPrint("An unexpected error occurred during sign up: $e");
      rethrow;
    }
  }

  // --- Sign In with Email and Password ---
  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        return User.fromFirebaseUser(userCredential.user!);
      }
      return null;
    } on fb_auth.FirebaseAuthException catch (e) {
      debugPrint(
        "Firebase Auth Exception during sign in: ${e.message} (Code: ${e.code})",
      );
      // e.g., if (e.code == 'user-not-found' || e.code == 'wrong-password') { ... }
      rethrow;
    } catch (e) {
      debugPrint("An unexpected error occurred during sign in: $e");
      rethrow;
    }
  }

  // --- Send Password Reset Email ---
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      debugPrint("Password reset email sent to $email");
    } on fb_auth.FirebaseAuthException catch (e) {
      debugPrint(
        "Error sending password reset email: ${e.message} (Code: ${e.code})",
      );
      rethrow;
    } catch (e) {
      debugPrint("An unexpected error occurred: $e");
      rethrow;
    }
  }

  // --- Update User Password (when user is logged in) ---
  Future<void> updatePassword({
    required String newPassword,
    required String oldPassword,
  }) async {
    final fbUser = _firebaseAuth.currentUser;
    if (fbUser == null) {
      throw Exception("User not logged in. Cannot update password.");
    }
    try {
      await signInWithEmailAndPassword(
        email: fbUser.email.toString(),
        password: oldPassword,
      );
      await fbUser.updatePassword(newPassword);
      debugPrint("Password updated successfully in Firebase.");
    } on fb_auth.FirebaseAuthException catch (e) {
      debugPrint("Error updating password: ${e.message} (Code: ${e.code})");
      // e.g., if (e.code == 'requires-recent-login') { ... }
      rethrow;
    } catch (e) {
      debugPrint("An unexpected error occurred updating password: $e");
      rethrow;
    }
  }

  // --- Update User Profile (Example: Display Name and Photo URL) ---
  Future<User?> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    final fbUser = _firebaseAuth.currentUser;
    if (fbUser == null) {
      throw Exception("User not logged in. Cannot update profile.");
    }
    try {
      if (displayName != null) {
        await fbUser.updateDisplayName(displayName);
      }
      if (photoURL != null) {
        await fbUser.updatePhotoURL(photoURL);
      }
      await fbUser.reload(); // Reload user data to get the latest profile
      final updatedFbUser =
          _firebaseAuth.currentUser; // Get the fresh user instance
      if (updatedFbUser != null) {
        return User.fromFirebaseUser(updatedFbUser);
      }
      return null;
    } on fb_auth.FirebaseAuthException catch (e) {
      debugPrint("Error updating profile: ${e.message} (Code: ${e.code})");
      rethrow;
    } catch (e) {
      debugPrint("An unexpected error occurred updating profile: $e");
      rethrow;
    }
  }

  // --- Send Email Verification ---
  Future<void> sendEmailVerification() async {
    final fbUser = _firebaseAuth.currentUser;
    if (fbUser != null && !fbUser.emailVerified) {
      try {
        await fbUser.sendEmailVerification();
        debugPrint("Verification email sent.");
      } on fb_auth.FirebaseAuthException catch (e) {
        debugPrint(
          "Error sending verification email: ${e.message} (Code: ${e.code})",
        );
        rethrow;
      } catch (e) {
        debugPrint("An unexpected error occurred: $e");
        rethrow;
      }
    } else if (fbUser == null) {
      debugPrint("Cannot send verification email: User not logged in.");
    } else {
      debugPrint("Email is already verified.");
    }
  }

  // --- Delete User Account ---
  Future<void> deleteUserAccount() async {
    final fbUser = _firebaseAuth.currentUser;
    if (fbUser == null) {
      throw Exception("User not logged in. Cannot delete account.");
    }
    try {
      await fbUser.delete();
      debugPrint("User account deleted successfully.");
    } on fb_auth.FirebaseAuthException catch (e) {
      debugPrint("Error deleting user account: ${e.message} (Code: ${e.code})");
      // e.g., if (e.code == 'requires-recent-login') { ... }
      rethrow;
    } catch (e) {
      debugPrint("An unexpected error occurred deleting account: $e");
      rethrow;
    }
  }

  // --- Sign Out ---
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      debugPrint("User signed out successfully from Firebase.");
    } catch (e) {
      debugPrint("Error signing out: $e");
      rethrow;
    }
  }
}
