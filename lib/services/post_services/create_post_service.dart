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

        await docRef.set(post.toMap());
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

  // Get all posts
  Stream<List<PostDataModel>> getPosts() {
    try {
      return _firestore.collection(_collection).snapshots().map((snapshot) {
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

        // Sort posts by postTime in descending order
        posts.sort((a, b) => b.postTime.compareTo(a.postTime));
        return posts;
      });
    } catch (e) {
      debugPrint('Error getting posts: $e');
      throw Exception('Failed to get posts: $e');
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
