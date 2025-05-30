import 'package:facebook_clone/models/post_data_model.dart';
import 'package:facebook_clone/services/post_services/comment_service.dart';
import 'package:facebook_clone/services/post_services/like_service.dart';
import 'package:flutter/material.dart';
import 'package:facebook_clone/services/auth_services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../utils/image_utils.dart';
import '../../widgets/custom_text.dart';
import 'comments_modal_sheet.dart';

/// A widget that displays a single post item with its content, interactions, and metadata.
class PostItem extends StatefulWidget {
  final PostDataModel postData;

  const PostItem({super.key, required this.postData});

  @override
  State<PostItem> createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  final CommentService _commentService = CommentService();
  final LikeService _likeService = LikeService();
  int _likesCount = 0;
  late final TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
    _likesCount = widget.postData.likesCount;
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  /// Handles the like/unlike action for the post
  Future<void> _handleLike() async {
    final user = AuthService().currentUser;
    if (user == null) return;

    try {
      await _likeService.toggleLike(widget.postData.documentId, user.uid);
    } catch (e) {
      debugPrint('Error toggling like: $e');
    }
  }

  /// Shows the comments modal and handles comment submission
  void _showCommentsModal() {
    showCommentsModal(
      context: context,
      postId: widget.postData.postId,
      controller: _commentController,
      onCommentSent: _handleCommentSubmission,
    );
  }

  /// Handles the submission of a new comment
  Future<void> _handleCommentSubmission(String comment) async {
    try {
      final user = AuthService().currentUser;
      if (user != null) {
        await _commentService.addComment(
          postId: widget.postData.postId,
          commentText: comment,
          user: user,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send comment: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final estimatedImageHeight = screenWidth * (9 / 16);
    final user = AuthService().currentUser;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUserSection(),
        const SizedBox(height: 10),
        CustomText(widget.postData.postText),
        const SizedBox(height: 10),
        if (widget.postData.postImageUrl.isNotEmpty)
          _buildPostImage(estimatedImageHeight),
        const SizedBox(height: 10),
        _buildReactsSection(),
        const SizedBox(height: 15),
        _buildInteractionButtons(user),
      ],
    );
  }

  Widget _buildUserSection() {
    return Row(
      children: [
        _buildProfileImage(),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              widget.postData.username,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            CustomText(
              _getTimeAgo(widget.postData.postTime.toDate()),
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileImage() {
    return widget.postData.profileImageUrl.isNotEmpty
        ? CircleAvatar(
            radius: 27,
            backgroundImage:
                ImageUtils.getImageProvider(widget.postData.profileImageUrl),
          )
        : const CircleAvatar(
            radius: 27,
            child: Icon(Icons.person),
          );
  }

  Widget _buildPostImage(double height) {
    return Image(
      image: ImageUtils.getImageProvider(widget.postData.postImageUrl),
      width: double.infinity,
      fit: BoxFit.fill,
      height: height,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: double.infinity,
          height: height,
          color: Colors.grey[300],
          child: const Icon(Icons.error_outline, size: 50),
        );
      },
    );
  }

  Widget _buildReactsSection() {
    return StreamBuilder<int>(
      stream: _likeService.getLikesCountStream(widget.postData.documentId),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _likesCount = snapshot.data!;
        }
        return InkWell(
          onTap: _showCommentsModal,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Row(
                children: [
                  const Icon(Icons.thumb_up, size: 14),
                  const SizedBox(width: 4),
                  CustomText(
                    '$_likesCount ${_likesCount == 1 ? 'like' : 'likes'}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  const Spacer(),
                  CustomText(
                    '${widget.postData.commentsCount} ${widget.postData.commentsCount == 1 ? 'comment' : 'comments'}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(width: 20),
                  CustomText(
                    '${widget.postData.sharesCount} ${widget.postData.sharesCount == 1 ? 'share' : 'shares'}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInteractionButtons(User? user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildLikeButton(user),
          _buildCommentButton(),
          _buildShareButton(),
        ],
      ),
    );
  }

  Widget _buildLikeButton(User? user) {
    if (user == null) return const SizedBox.shrink();

    return StreamBuilder<bool>(
      stream: _likeService.getLikeStatusStream(
          widget.postData.documentId, user.uid),
      builder: (context, snapshot) {
        final isLiked = snapshot.data ?? false;
        return InkWell(
          onTap: _handleLike,
          child: Row(
            children: [
              Icon(
                isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                color: isLiked ? Colors.blue : null,
              ),
              const SizedBox(width: 5),
              CustomText(
                'Like',
                style: TextStyle(
                  fontSize: 12,
                  color: isLiked ? Colors.blue : null,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCommentButton() {
    return InkWell(
      onTap: _showCommentsModal,
      child: Row(
        children: const [
          Icon(Icons.comment),
          SizedBox(width: 5),
          CustomText('Comment', style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildShareButton() {
    return Row(
      children: const [
        Icon(Icons.share),
        SizedBox(width: 5),
        CustomText('Share', style: TextStyle(fontSize: 12)),
      ],
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}
