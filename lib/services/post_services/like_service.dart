import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class LikeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _postsCollection = 'posts';
  final String _likesCollection = 'likes';

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

  // Toggle like for a post
  Future<void> toggleLike(
      String postId, String userId, String displayName) async {
    try {
      final likeRef =
          _firestore.collection(_likesCollection).doc('${postId}_$userId');
      final postRef = _firestore.collection(_postsCollection).doc(postId);

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
