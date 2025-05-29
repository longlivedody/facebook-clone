import 'package:cloud_firestore/cloud_firestore.dart';

class CommentsModel {
  final String userImgUrl;
  final String username;
  final String comment;
  final DateTime timestamp;
  final String userId;

  CommentsModel({
    required this.userImgUrl,
    required this.username,
    required this.comment,
    required this.timestamp,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'userImgUrl': userImgUrl,
      'username': username,
      'comment': comment,
      'timestamp': timestamp,
      'userId': userId,
    };
  }

  factory CommentsModel.fromMap(Map<String, dynamic> map) {
    return CommentsModel(
      userImgUrl: map['userImgUrl'] ?? '',
      username: map['username'] ?? 'Anonymous',
      comment: map['comment'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      userId: map['userId'] ?? '',
    );
  }

  // Sample comments, now with postId
}
