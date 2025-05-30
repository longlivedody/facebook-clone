import 'package:facebook_clone/models/post_data_model.dart';
import 'package:facebook_clone/services/post_services/comment_service.dart';
import 'package:facebook_clone/services/post_services/like_service.dart';
import 'package:flutter/material.dart';
import 'package:facebook_clone/services/auth_services/auth_service.dart';

import '../../utils/image_utils.dart';
import '../../widgets/custom_text.dart';
import 'comments_modal_sheet.dart';

class PostItem extends StatefulWidget {
  final PostDataModel postData;

  const PostItem({super.key, required this.postData});

  @override
  State<PostItem> createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  final CommentService _commentService = CommentService();
  final LikeService _likeService = LikeService();
  bool _isLiked = false;
  int _likesCount = 0;

  @override
  void initState() {
    super.initState();
    _likesCount = widget.postData.likesCount;
    _checkInitialLikeStatus();
  }

  Future<void> _checkInitialLikeStatus() async {
    final user = AuthService().currentUser;
    if (user != null) {
      final hasLiked = await _likeService.hasUserLikedPost(
          widget.postData.documentId, user.uid);
      if (mounted) {
        setState(() {
          _isLiked = hasLiked;
        });
      }
    }
  }

  Future<void> _handleLike() async {
    final user = AuthService().currentUser;
    if (user == null) return;

    setState(() {
      _isLiked = !_isLiked;
      _likesCount += _isLiked ? 1 : -1;
    });

    try {
      await _likeService.toggleLike(
          widget.postData.documentId, user.uid, widget.postData.username);
    } catch (e) {
      // Revert the state if the operation fails
      setState(() {
        _isLiked = !_isLiked;
        _likesCount += _isLiked ? 1 : -1;
      });
      debugPrint('Error toggling like: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    final screenWidth = MediaQuery.of(context).size.width;
    final estimatedImageHeight = screenWidth * (9 / 16);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // profile image , name , post time
        userSection(
          username: widget.postData.username,
          profileImageUrl: widget.postData.profileImageUrl,
          postTime: _getTimeAgo(widget.postData.postTime.toDate()),
        ),
        const SizedBox(height: 10),
        // post content
        CustomText(widget.postData.postText),
        const SizedBox(height: 10),
        // post image
        if (widget.postData.postImageUrl.isNotEmpty)
          Image(
            image: ImageUtils.getImageProvider(widget.postData.postImageUrl),
            width: double.infinity,
            fit: BoxFit.fill,
            height: estimatedImageHeight,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: double.infinity,
                height: estimatedImageHeight,
                color: Colors.grey[300],
                child: const Icon(Icons.error_outline, size: 50),
              );
            },
          ),
        const SizedBox(height: 10),
        // likes , comment and shares
        InkWell(
          onTap: () {
            showCommentsModal(
              context: context,
              postId: widget.postData.postId,
              controller: controller,
              onCommentSent: (String comment) async {
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
                        content:
                            Text('Failed to send comment: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            );
          },
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Row(
                children: [
                  CustomText(
                      '$_likesCount ${_likesCount == 1 ? 'like' : 'likes'}',
                      style: const TextStyle(fontSize: 12)),
                  Spacer(),
                  CustomText(
                      '${widget.postData.commentsCount} ${widget.postData.commentsCount == 1 ? 'comment' : 'comments'}',
                      style: const TextStyle(fontSize: 12)),
                  SizedBox(
                    width: 20,
                  ),
                  CustomText(
                      '${widget.postData.sharesCount} ${widget.postData.sharesCount == 1 ? 'share' : 'shares'}',
                      style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),
        // buttons like , comment and share
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 25.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: _handleLike,
                child: Row(
                  children: [
                    Icon(
                      _isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                      color: _isLiked ? Colors.blue : null,
                    ),
                    SizedBox(width: 5),
                    CustomText(
                      'Like',
                      style: TextStyle(
                        fontSize: 12,
                        color: _isLiked ? Colors.blue : null,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  showCommentsModal(
                    context: context,
                    postId: widget.postData.postId,
                    controller: controller,
                    onCommentSent: (String comment) async {
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
                              content: Text(
                                  'Failed to send comment: ${e.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                  );
                },
                child: Row(
                  children: [
                    Icon(Icons.comment),
                    SizedBox(width: 5),
                    CustomText('Comment', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              Row(
                children: [
                  Icon(Icons.share),
                  SizedBox(width: 5),
                  CustomText('Share', style: TextStyle(fontSize: 12)),
                ],
              ),
            ],
          ),
        )
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

Widget userSection({
  required String username,
  required String profileImageUrl,
  required String postTime,
}) {
  return Row(
    children: [
      profileImageUrl != ''
          ? CircleAvatar(
              radius: 27,
              backgroundImage: ImageUtils.getImageProvider(profileImageUrl),
              onBackgroundImageError: (exception, stackTrace) {
                // Handle error if needed
              },
            )
          : CircleAvatar(
              radius: 27,
              child: Icon(
                Icons.person,
              ),
            ),
      const SizedBox(width: 8),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            username,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          CustomText(postTime, style: const TextStyle(fontSize: 12)),
        ],
      ),
    ],
  );
}
