import 'package:facebook_clone/widgets/custom_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../widgets/custom_text.dart';

/// A screen that displays the list of users who liked a specific post.
class LikesScreen extends StatelessWidget {
  final String postId;

  const LikesScreen({
    super.key,
    required this.postId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const Divider(height: 1),
            Expanded(
              child: _buildLikesList(),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the header section with back button and likes count
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        CustomIconButton(
          onPressed: () => Navigator.of(context).pop(),
          iconData: Icons.arrow_back_ios,
        ),
        _buildLikesCount(),
      ],
    );
  }

  /// Builds the likes count widget using a StreamBuilder
  Widget _buildLikesCount() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorWidget('Error loading likes');
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final postData = snapshot.data!.data() as Map<String, dynamic>;
        final likesCount = postData['likesCount'] ?? 0;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: CustomText(
            '$likesCount Like${likesCount == 1 ? "" : "s"}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }

  /// Builds the list of users who liked the post
  Widget _buildLikesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('likes')
          .where('postId', isEqualTo: postId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorWidget('Error loading likes');
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final likes = snapshot.data!.docs;

        if (likes.isEmpty) {
          return const Center(
            child: CustomText(
              'No likes yet',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          );
        }

        return ListView.separated(
          separatorBuilder: (_, __) => const Divider(),
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
          itemCount: likes.length,
          itemBuilder: (context, index) =>
              _buildLikeItem(likes[index].data() as Map<String, dynamic>),
        );
      },
    );
  }

  /// Builds a single like item in the list
  Widget _buildLikeItem(Map<String, dynamic> like) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.thumb_up,
            color: Colors.blue,
            size: 30,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: CustomText(
              like['displayName'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds an error widget with the given message
  Widget _buildErrorWidget(String message) {
    return Center(
      child: CustomText(
        message,
        style: const TextStyle(color: Colors.red),
      ),
    );
  }
}
