// In your models/post_data_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'comments_model.dart'; // Make sure this import is correct

class PostDataModel {
  final int postId;
  final String username;
  final String profileImageUrl;
  final String postText;
  final String postImageUrl;
  final Timestamp postTime;
  final int likesCount;
  final int sharesCount;
  final List<CommentsModel> comments;
  final String userId;
  final String documentId;

  PostDataModel({
    required this.postId,
    required this.username,
    required this.profileImageUrl,
    required this.postText,
    required this.postImageUrl,
    required this.postTime,
    required this.likesCount,
    required this.sharesCount,
    required this.comments,
    required this.userId,
    required this.documentId,
  });

  int get commentsCount => comments.length;

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'username': username,
      'profileImageUrl': profileImageUrl,
      'postText': postText,
      'postImageUrl': postImageUrl,
      'postTime': postTime,
      'likesCount': likesCount,
      'sharesCount': sharesCount,
      'comments': comments.map((comment) => comment.toMap()).toList(),
      'userId': userId,
    };
  }

  factory PostDataModel.fromMap(Map<String, dynamic> map) {
    return PostDataModel(
      postId: map['postId'] ?? 0,
      username: map['username'] ?? 'Anonymous',
      profileImageUrl: map['profileImageUrl'] ?? '',
      postText: map['postText'] ?? '',
      postImageUrl: map['postImageUrl'] ?? '',
      postTime: map['postTime'] ?? Timestamp.now(),
      likesCount: map['likesCount'] ?? 0,
      sharesCount: map['sharesCount'] ?? 0,
      comments: (map['comments'] as List<dynamic>?)
              ?.map((comment) => CommentsModel.fromMap(comment))
              .toList() ??
          [],
      userId: map['userId'] ?? '',
      documentId: map['documentId'] ?? '',
    );
  }
}
