import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:facebook_clone/services/auth_services/auth_service.dart';

class LikeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _postsCollection = 'posts';
  final String _likesCollection = 'likes';
  final AuthService _authService = AuthService();

  // Check if user has liked a post
  Future<bool> hasUserLikedPost(String postId, String userId) async {
    try {
      final likeDoc = await _firestore
          .collection(_likesCollection)
          .doc('${postId}_$userId')
          .get();
      return likeDoc.exists;
    } catch (e) {
      debugPrint('Error checking like status: $e');
      return false;
    }
  }

  // Get stream of like status for a post and user
  Stream<bool> getLikeStatusStream(String postId, String userId) {
    return _firestore
        .collection(_likesCollection)
        .doc('${postId}_$userId')
        .snapshots()
        .map((snapshot) => snapshot.exists);
  }

  // Get stream of likes count for a post
  Stream<int> getLikesCountStream(String postId) {
    return _firestore
        .collection(_postsCollection)
        .doc(postId)
        .snapshots()
        .map((snapshot) => snapshot.data()?['likesCount'] ?? 0);
  }

  // Toggle like for a post
  Future<void> toggleLike(String postId, String userId) async {
    try {
      final likeRef =
          _firestore.collection(_likesCollection).doc('${postId}_$userId');
      final postRef = _firestore.collection(_postsCollection).doc(postId);

      // Get current user's display name
      final currentUser = _authService.currentUser;
      final displayName = currentUser?.displayName ?? 'Anonymous';

      await _firestore.runTransaction((transaction) async {
        final likeDoc = await transaction.get(likeRef);
        final postDoc = await transaction.get(postRef);

        if (!postDoc.exists) return;

        final currentLikes = postDoc.data()?['likesCount'] ?? 0;

        if (likeDoc.exists) {
          // Unlike
          transaction.delete(likeRef);
          transaction.update(postRef, {'likesCount': currentLikes - 1});
        } else {
          // Like
          transaction.set(likeRef, {
            'userId': userId,
            'postId': postId,
            'displayName': displayName,
            'timestamp': Timestamp.now(),
          });
          transaction.update(postRef, {'likesCount': currentLikes + 1});
        }
      });
    } catch (e) {
      debugPrint('Error toggling like: $e');
      throw Exception('Failed to toggle like: $e');
    }
  }
}
