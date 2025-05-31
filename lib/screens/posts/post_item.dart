import 'package:facebook_clone/models/post_data_model.dart';
import 'package:facebook_clone/services/auth_services/auth_service.dart';
import 'package:facebook_clone/services/post_services/comment_service.dart';
import 'package:facebook_clone/services/post_services/like_service.dart';
import 'package:flutter/material.dart';

import '../../utils/image_utils.dart';
import '../../widgets/custom_text.dart';
import 'comments_modal_sheet.dart';
import 'package:facebook_clone/services/post_services/create_post_service.dart';
import 'update_post_screen.dart';

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
  final PostService _postService = PostService();
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send comment: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Handles the deletion of the post
  Future<void> _handleDeletePost() async {
    try {
      final user = AuthService().currentUser;
      if (user == null) return;

      // Show confirmation dialog
      final bool? confirm = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Delete Post'),
            content: const Text('Are you sure you want to delete this post?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  'Delete',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ],
          );
        },
      );

      if (confirm == true) {
        await _postService.deletePost(widget.postData.documentId, user.uid);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post deleted successfully')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete post: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Handles the update of the post
  void _handleUpdatePost() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdatePostScreen(post: widget.postData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final estimatedImageHeight = screenWidth * 1.1;
    final user = AuthService().currentUser;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUserSection(),
        const SizedBox(height: 16),
        CustomText(
          widget.postData.postText,
          style: theme.textTheme.bodyLarge,
        ),
        if (widget.postData.postImageUrl.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildPostImage(estimatedImageHeight),
        ],
        const SizedBox(height: 16),
        _buildReactsSection(),
        // const Divider(height: 24),
        _buildInteractionButtons(user),
      ],
    );
  }

  Widget _buildUserSection() {
    final theme = Theme.of(context);
    return Row(
      children: [
        _buildProfileImage(),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                widget.postData.username,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              CustomText(
                _getTimeAgo(widget.postData.postTime.toDate()),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(80),
                ),
              ),
            ],
          ),
        ),
        if (AuthService().currentUser?.uid == widget.postData.userId)
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_horiz,
              color: theme.colorScheme.onSurface.withAlpha(60),
            ),
            onSelected: (value) {
              if (value == 'delete') {
                _handleDeletePost();
              } else if (value == 'update') {
                _handleUpdatePost();
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'update',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    const Text('Update Post'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: theme.colorScheme.error),
                    const SizedBox(width: 8),
                    Text(
                      'Delete Post',
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildProfileImage() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withAlpha(20),
          width: 2,
        ),
      ),
      child: widget.postData.profileImageUrl.isNotEmpty
          ? CircleAvatar(
              radius: 24,
              backgroundImage:
                  ImageUtils.getImageProvider(widget.postData.profileImageUrl),
            )
          : CircleAvatar(
              radius: 24,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.person,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
    );
  }

  Widget _buildPostImage(double height) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image(
        image: ImageUtils.getImageProvider(widget.postData.postImageUrl),
        width: double.infinity,
        fit: BoxFit.cover,
        height: height,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: double.infinity,
            height: height,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Icon(
              Icons.error_outline,
              size: 50,
              color: Theme.of(context).colorScheme.error,
            ),
          );
        },
      ),
    );
  }

  Widget _buildReactsSection() {
    final theme = Theme.of(context);
    return StreamBuilder<int>(
      stream: _likeService.getLikesCountStream(widget.postData.documentId),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _likesCount = snapshot.data!;
        }
        return InkWell(
          onTap: _showCommentsModal,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                (_likesCount) != 0
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.thumb_up,
                              size: 14,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                            CustomText(
                              '$_likesCount',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(),
                Spacer(),
                (widget.postData.commentsCount) != 0
                    ? CustomText(
                        '${widget.postData.commentsCount} comments',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withAlpha(150),
                        ),
                      )
                    : Container(),
                const SizedBox(width: 20),
                (widget.postData.sharesCount) != 0
                    ? CustomText(
                        '${widget.postData.sharesCount} shares',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withAlpha(150),
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInteractionButtons(User? user) {
    // final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
    final theme = Theme.of(context);

    return StreamBuilder<bool>(
      stream: _likeService.getLikeStatusStream(
          widget.postData.documentId, user.uid),
      builder: (context, snapshot) {
        final isLiked = snapshot.data ?? false;
        return TextButton.icon(
          onPressed: _handleLike,
          icon: Icon(
            isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
            color: isLiked
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withAlpha(150),
          ),
          label: CustomText(
            'Like',
            style: theme.textTheme.labelLarge?.copyWith(
              color: isLiked
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withAlpha(150),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCommentButton() {
    final theme = Theme.of(context);
    return TextButton.icon(
      onPressed: _showCommentsModal,
      icon: Icon(
        Icons.comment_outlined,
        color: theme.colorScheme.onSurface.withAlpha(150),
      ),
      label: CustomText(
        'Comment',
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.onSurface.withAlpha(150),
        ),
      ),
    );
  }

  Widget _buildShareButton() {
    final theme = Theme.of(context);
    return TextButton.icon(
      onPressed: () {},
      icon: Icon(
        Icons.share_outlined,
        color: theme.colorScheme.onSurface.withAlpha(150),
      ),
      label: CustomText(
        'Share',
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.onSurface.withAlpha(150),
        ),
      ),
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
