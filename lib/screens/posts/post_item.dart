import 'package:facebook_clone/models/post_data_model.dart';
import 'package:facebook_clone/services/comment_service.dart';
import 'package:flutter/material.dart';
import 'package:facebook_clone/services/auth_service.dart';

import '../../utils/image_utils.dart';
import '../../widgets/custom_text.dart';
import 'comments_modal_sheet.dart';

class PostItem extends StatelessWidget {
  final PostDataModel postData;
  final CommentService _commentService = CommentService();

  PostItem({super.key, required this.postData});

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
          username: postData.username,
          profileImageUrl: postData.profileImageUrl,
          postTime: _getTimeAgo(postData.postTime.toDate()),
        ),
        const SizedBox(height: 10),
        // post content
        CustomText(postData.postText),
        const SizedBox(height: 10),
        // post image
        if (postData.postImageUrl.isNotEmpty)
          Image(
            image: ImageUtils.getImageProvider(postData.postImageUrl),
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
        GestureDetector(
          onTap: () {
            showCommentsModal(
              context: context,
              comments: postData.comments,
              controller: controller,
              onCommentSent: (String comment) async {
                try {
                  final user = AuthService().currentUser;
                  if (user != null) {
                    await _commentService.addComment(
                      postId: postData.postId,
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
          child: reactsCommentsShares(
            likesCount: postData.likesCount,
            commentsCount: postData.commentsCount,
            sharesCount: postData.sharesCount,
          ),
        ),
        const SizedBox(height: 15),
        // buttons like , comment and share
        actionsSection(),
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

Widget reactsCommentsShares({
  required int likesCount,
  required int commentsCount,
  required int sharesCount,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomText('$likesCount likes', style: const TextStyle(fontSize: 12)),
        CustomText('$commentsCount comments',
            style: const TextStyle(fontSize: 12)),
        CustomText('$sharesCount shares', style: const TextStyle(fontSize: 12)),
      ],
    ),
  );
}

Widget actionsSection() {
  return const Padding(
    padding: EdgeInsets.symmetric(horizontal: 25.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.thumb_up_alt_outlined),
            SizedBox(width: 5),
            CustomText('Like', style: TextStyle(fontSize: 12)),
          ],
        ),
        Row(
          children: [
            Icon(Icons.comment),
            SizedBox(width: 5),
            CustomText('Comment', style: TextStyle(fontSize: 12)),
          ],
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
  );
}
