import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:facebook_clone/models/comments_model.dart';
import 'package:facebook_clone/services/auth_service.dart';
import 'package:flutter/material.dart';

class CommentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const int _maxRetries = 3;
  final String _collection = 'posts';

  // Add a method to add a comment to a post
  Future<void> addComment({
    required int postId,
    required String commentText,
    required User user,
  }) async {
    int retryCount = 0;
    while (retryCount < _maxRetries) {
      try {
        final comment = CommentsModel(
          userImgUrl: user.photoURL ?? '',
          username: user.displayName ?? 'Anonymous',
          comment: commentText,
          timestamp: DateTime.now(),
          userId: user.uid,
        );

        // Find the post document by postId
        final querySnapshot = await _firestore
            .collection(_collection)
            .where('postId', isEqualTo: postId)
            .get();

        if (querySnapshot.docs.isEmpty) {
          throw Exception('Post not found');
        }

        final postDoc = querySnapshot.docs.first;
        await postDoc.reference.update({
          'comments': FieldValue.arrayUnion([comment.toMap()])
        });
        return;
      } catch (e) {
        retryCount++;
        if (retryCount == _maxRetries) {
          debugPrint('Error adding comment after $_maxRetries attempts: $e');
          throw Exception('Failed to add comment: $e');
        }
        await Future.delayed(Duration(seconds: retryCount));
      }
    }
  }

  // Stream comments for a specific post
  Stream<List<CommentsModel>> getComments(int postId) {
    return _firestore
        .collection(_collection)
        .where('postId', isEqualTo: postId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return [];

      final postData = snapshot.docs.first.data();
      final comments = postData['comments'] as List<dynamic>? ?? [];

      return comments
          .map((comment) =>
              CommentsModel.fromMap(comment as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.timestamp
            .compareTo(a.timestamp)); // Sort by timestamp in descending order
    });
  }
}
