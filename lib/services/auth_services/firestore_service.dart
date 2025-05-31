import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUserProfile({
    required String uid,
    required String email,
    String? displayName,
    String? profileImageBase64,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'email': email,
        'displayName': displayName,
        'profileImage': profileImageBase64,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'postsCount': 0,
        'likesCount': 0,
      });
    } catch (e) {
      throw Exception('Failed to create user profile: $e');
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data();
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  Future<void> updateUserProfile({
    required String uid,
    String? displayName,
    String? profileImageBase64,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (displayName != null) updates['displayName'] = displayName;
      if (profileImageBase64 != null) {
        updates['profileImage'] = profileImageBase64;
      }

      await _firestore.collection('users').doc(uid).update(updates);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  Future<void> deleteUserProfile(String uid) async {
    try {
      // Delete user's posts
      final postsSnapshot = await _firestore
          .collection('posts')
          .where('userId', isEqualTo: uid)
          .get();

      final batch = _firestore.batch();
      for (var doc in postsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Delete user's likes
      final likesSnapshot = await _firestore
          .collection('likes')
          .where('userId', isEqualTo: uid)
          .get();

      for (var doc in likesSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Delete user profile
      batch.delete(_firestore.collection('users').doc(uid));

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete user profile: $e');
    }
  }

  Stream<Map<String, dynamic>?> getUserProfileStream(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.data());
  }
}
