import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:facebook_clone/services/auth_services/auth_service.dart';
import 'dart:async';

class LikeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _postsCollection = 'posts';
  final String _likesCollection = 'likes';
  final AuthService _authService = AuthService();

  // Cache for likes count and status
  final Map<String, int> _likesCountCache = {};
  final Map<String, StreamController<int>> _likesCountControllers = {};
  final Map<String, bool> _likeStatusCache = {};
  final Map<String, StreamController<bool>> _likeStatusControllers = {};

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

  // Get stream of like status for a post and user with caching
  Stream<bool> getLikeStatusStream(String postId, String userId) {
    final cacheKey = '${postId}_$userId';

    // Return cached stream if it exists
    if (_likeStatusControllers.containsKey(cacheKey)) {
      return _likeStatusControllers[cacheKey]!.stream;
    }

    // Create new stream controller
    final controller = StreamController<bool>();
    _likeStatusControllers[cacheKey] = controller;

    // Initialize with cached value if available
    if (_likeStatusCache.containsKey(cacheKey)) {
      controller.add(_likeStatusCache[cacheKey]!);
    }

    // Listen to Firestore updates
    final subscription = _firestore
        .collection(_likesCollection)
        .doc(cacheKey)
        .snapshots()
        .listen((snapshot) {
      final isLiked = snapshot.exists;
      _likeStatusCache[cacheKey] = isLiked;
      controller.add(isLiked);
    });

    // Clean up when stream is cancelled
    controller.onCancel = () {
      subscription.cancel();
      _likeStatusControllers.remove(cacheKey);
    };

    return controller.stream;
  }

  // Get stream of likes count for a post with caching
  Stream<int> getLikesCountStream(String postId) {
    // Return cached stream if it exists
    if (_likesCountControllers.containsKey(postId)) {
      return _likesCountControllers[postId]!.stream;
    }

    // Create new stream controller
    final controller = StreamController<int>();
    _likesCountControllers[postId] = controller;

    // Initialize with cached value if available
    if (_likesCountCache.containsKey(postId)) {
      controller.add(_likesCountCache[postId]!);
    }

    // Listen to Firestore updates
    final subscription = _firestore
        .collection(_postsCollection)
        .doc(postId)
        .snapshots()
        .listen((snapshot) {
      final likesCount = snapshot.data()?['likesCount'] ?? 0;
      _likesCountCache[postId] = likesCount;
      controller.add(likesCount);
    });

    // Clean up when stream is cancelled
    controller.onCancel = () {
      subscription.cancel();
      _likesCountControllers.remove(postId);
    };

    return controller.stream;
  }

  // Get users who liked a post
  Stream<List<Map<String, dynamic>>> getPostLikes(String postId) {
    return _firestore
        .collection(_likesCollection)
        .where('postId', isEqualTo: postId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'userId': data['userId'],
          'displayName': data['displayName'],
          'timestamp': data['timestamp'],
        };
      }).toList();
    });
  }

  // Get posts liked by a user
  Stream<List<String>> getUserLikedPosts(String userId) {
    return _firestore
        .collection(_likesCollection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => doc.data()['postId'] as String)
          .toList();
    });
  }

  // Toggle like for a post with optimistic updates
  Future<void> toggleLike(String postId, String userId) async {
    final cacheKey = '${postId}_$userId';
    try {
      final likeRef = _firestore.collection(_likesCollection).doc(cacheKey);
      final postRef = _firestore.collection(_postsCollection).doc(postId);
      final userRef = _firestore.collection('users').doc(userId);

      // Get current user's display name
      final currentUser = _authService.currentUser;
      final displayName = currentUser?.displayName ?? 'Anonymous';

      // Get current like status
      final isLiked =
          _likeStatusCache[cacheKey] ?? await hasUserLikedPost(postId, userId);

      // Optimistically update local cache for both likes count and status
      final currentLikes = _likesCountCache[postId] ?? 0;
      final newLikesCount = isLiked ? currentLikes - 1 : currentLikes + 1;

      // Update caches and notify listeners
      _likesCountCache[postId] = newLikesCount;
      _likesCountControllers[postId]?.add(newLikesCount);

      _likeStatusCache[cacheKey] = !isLiked;
      _likeStatusControllers[cacheKey]?.add(!isLiked);

      await _firestore.runTransaction((transaction) async {
        final likeDoc = await transaction.get(likeRef);
        final postDoc = await transaction.get(postRef);
        final userDoc = await transaction.get(userRef);

        if (!postDoc.exists) return;

        if (likeDoc.exists) {
          // Unlike
          transaction.delete(likeRef);
          transaction.update(postRef, {'likesCount': newLikesCount});

          // Update user's likes count
          if (userDoc.exists) {
            final currentLikesCount = userDoc.data()?['likesCount'] ?? 0;
            if (currentLikesCount > 0) {
              transaction
                  .update(userRef, {'likesCount': currentLikesCount - 1});
            }
          }
        } else {
          // Like
          transaction.set(likeRef, {
            'userId': userId,
            'postId': postId,
            'displayName': displayName,
            'timestamp': Timestamp.now(),
          });
          transaction.update(postRef, {'likesCount': newLikesCount});

          // Update user's likes count
          if (userDoc.exists) {
            final currentLikesCount = userDoc.data()?['likesCount'] ?? 0;
            transaction.update(userRef, {'likesCount': currentLikesCount + 1});
          }
        }
      });
    } catch (e) {
      // Revert optimistic updates on error
      final isLiked =
          _likeStatusCache[cacheKey] ?? await hasUserLikedPost(postId, userId);
      final currentLikes = _likesCountCache[postId] ?? 0;
      final revertedLikesCount = isLiked ? currentLikes + 1 : currentLikes - 1;

      // Revert likes count
      _likesCountCache[postId] = revertedLikesCount;
      _likesCountControllers[postId]?.add(revertedLikesCount);

      // Revert like status
      _likeStatusCache[cacheKey] = isLiked;
      _likeStatusControllers[cacheKey]?.add(isLiked);

      debugPrint('Error toggling like: $e');
      throw Exception('Failed to toggle like: $e');
    }
  }

  // Get total likes count for a user
  Future<int> getUserTotalLikes(String userId) async {
    try {
      final likesSnapshot = await _firestore
          .collection(_likesCollection)
          .where('userId', isEqualTo: userId)
          .count()
          .get();
      return likesSnapshot.count ?? 0;
    } catch (e) {
      debugPrint('Error getting user total likes: $e');
      return 0;
    }
  }
}
