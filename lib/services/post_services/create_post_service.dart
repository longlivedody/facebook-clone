import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:facebook_clone/models/post_data_model.dart';
import 'package:facebook_clone/models/comments_model.dart';
import 'package:facebook_clone/services/auth_services/auth_service.dart';
import 'package:flutter/foundation.dart';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'posts';
  static const int _maxRetries = 3;

  // Create a new post
  Future<void> createPost({
    required String postText,
    String? postImageUrl,
    required User user,
  }) async {
    int retryCount = 0;
    while (retryCount < _maxRetries) {
      try {
        // Create a new document reference to get the ID
        final docRef = _firestore.collection(_collection).doc();

        final post = PostDataModel(
          postId: DateTime.now().millisecondsSinceEpoch,
          username: user.displayName ?? 'Anonymous',
          profileImageUrl: user.photoURL ?? '',
          postText: postText,
          postImageUrl: postImageUrl ?? '',
          postTime: Timestamp.now(),
          likesCount: 0,
          sharesCount: 0,
          comments: [],
          userId: user.uid,
          documentId: docRef.id,
        );

        // Create the post first
        await docRef.set(post.toMap());

        // Then update user's post count
        final userRef = _firestore.collection('users').doc(user.uid);
        await userRef.update({'postsCount': FieldValue.increment(1)});

        return;
      } catch (e) {
        retryCount++;
        if (retryCount == _maxRetries) {
          debugPrint('Error creating post after $_maxRetries attempts: $e');
          throw Exception('Failed to create post: $e');
        }
        await Future.delayed(Duration(seconds: retryCount));
      }
    }
  }

  // Update an existing post
  Future<void> updatePost({
    required String documentId,
    required String postText,
    String? postImageUrl,
    required String userId,
  }) async {
    int retryCount = 0;
    while (retryCount < _maxRetries) {
      try {
        final postRef = _firestore.collection(_collection).doc(documentId);
        final postDoc = await postRef.get();

        if (!postDoc.exists) {
          throw Exception('Post not found');
        }

        if (postDoc.data()?['userId'] != userId) {
          throw Exception('Not authorized to update this post');
        }

        await postRef.update({
          'postText': postText,
          'postImageUrl': postImageUrl ?? '',
          'updatedAt': FieldValue.serverTimestamp(),
        });
        return;
      } catch (e) {
        retryCount++;
        if (retryCount == _maxRetries) {
          debugPrint('Error updating post after $_maxRetries attempts: $e');
          throw Exception('Failed to update post: $e');
        }
        await Future.delayed(Duration(seconds: retryCount));
      }
    }
  }

  // Get all posts
  Stream<List<PostDataModel>> getPosts() {
    try {
      return _firestore
          .collection(_collection)
          .orderBy('postTime', descending: true)
          .snapshots()
          .map((snapshot) {
        final posts = snapshot.docs.map((doc) {
          final data = doc.data();
          final comments = (data['comments'] as List<dynamic>?)?.map((comment) {
                return CommentsModel.fromMap(comment);
              }).toList() ??
              [];

          return PostDataModel(
            postId: data['postId'] ?? 0,
            username: data['username'] ?? 'Anonymous',
            profileImageUrl: data['profileImageUrl'] ?? '',
            postText: data['postText'] ?? '',
            postImageUrl: data['postImageUrl'] ?? '',
            likesCount: data['likesCount'] ?? 0,
            sharesCount: data['sharesCount'] ?? 0,
            postTime: data['postTime'],
            comments: comments,
            userId: data['userId'] ?? '',
            documentId: doc.id,
          );
        }).toList();

        return posts;
      });
    } catch (e) {
      debugPrint('Error getting posts: $e');
      throw Exception('Failed to get posts: $e');
    }
  }

  // Get user's posts
  Stream<List<PostDataModel>> getUserPosts(String userId) {
    try {
      return _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('postTime', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          final comments = (data['comments'] as List<dynamic>?)?.map((comment) {
                return CommentsModel.fromMap(comment);
              }).toList() ??
              [];

          return PostDataModel(
            postId: data['postId'] ?? 0,
            username: data['username'] ?? 'Anonymous',
            profileImageUrl: data['profileImageUrl'] ?? '',
            postText: data['postText'] ?? '',
            postImageUrl: data['postImageUrl'] ?? '',
            likesCount: data['likesCount'] ?? 0,
            sharesCount: data['sharesCount'] ?? 0,
            postTime: data['postTime'],
            comments: comments,
            userId: data['userId'] ?? '',
            documentId: doc.id,
          );
        }).toList();
      });
    } catch (e) {
      debugPrint('Error getting user posts: $e');
      throw Exception('Failed to get user posts: $e');
    }
  }

  // Delete a post by document ID
  Future<void> deletePost(String documentId, String userId) async {
    int retryCount = 0;
    while (retryCount < _maxRetries) {
      try {
        final postRef = _firestore.collection(_collection).doc(documentId);
        final postDoc = await postRef.get();

        if (!postDoc.exists) {
          throw Exception('Post not found');
        }

        if (postDoc.data()?['userId'] != userId) {
          throw Exception('Not authorized to delete this post');
        }

        // Delete all likes associated with this post
        final likesSnapshot = await _firestore
            .collection('likes')
            .where('postId', isEqualTo: documentId)
            .get();

        // Delete likes first
        for (var doc in likesSnapshot.docs) {
          await doc.reference.delete();
        }

        // Then delete the post
        await postRef.delete();

        // Finally update user's posts count
        final userRef = _firestore.collection('users').doc(userId);
        await userRef.update({'postsCount': FieldValue.increment(-1)});
        await userRef.update({'likesCount': FieldValue.increment(-1)});

        return;
      } catch (e) {
        retryCount++;
        if (retryCount == _maxRetries) {
          debugPrint('Error deleting post after $_maxRetries attempts: $e');
          throw Exception('Failed to delete post: $e');
        }
        await Future.delayed(Duration(seconds: retryCount));
      }
    }
  }

  // Check Firestore connection
  Future<bool> checkConnection() async {
    int retryCount = 0;
    while (retryCount < _maxRetries) {
      try {
        await _firestore.collection(_collection).limit(1).get();
        return true;
      } catch (e) {
        retryCount++;
        if (retryCount == _maxRetries) {
          debugPrint(
              'Firestore connection error after $_maxRetries attempts: $e');
          return false;
        }
        await Future.delayed(Duration(seconds: retryCount));
      }
    }
    return false;
  }
}
