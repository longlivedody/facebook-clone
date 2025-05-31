import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/comments_model.dart';
import '../../services/post_services/comment_service.dart';
import '../../services/auth_services/auth_service.dart';
import '../../widgets/custom_text.dart';
import 'likes_screen.dart';

void showCommentsModal({
  required BuildContext context,
  required int postId,
  required TextEditingController controller,
  required Function(String) onCommentSent,
}) {
  final commentService = CommentService();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
    ),
    builder: (BuildContext modalContext) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.9,
        minChildSize: 0.3,
        maxChildSize: 1,
        builder: (BuildContext context, ScrollController scrollController) {
          return Container(
            padding: const EdgeInsets.only(top: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 100,
                    height: 5,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                // Post Stats Header
                StreamBuilder<DocumentSnapshot>(
                  stream: firestore
                      .collection('posts')
                      .where('postId', isEqualTo: postId)
                      .snapshots()
                      .map((snapshot) => snapshot.docs.first),
                  builder: (context, postSnapshot) {
                    if (postSnapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: CustomText(
                          'Error loading post data',
                          style: TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    if (!postSnapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final postData =
                        postSnapshot.data!.data() as Map<String, dynamic>;
                    final likesCount = postData['likesCount'] ?? 0;
                    final documentId = postSnapshot.data!.id;

                    return StreamBuilder<List<CommentsModel>>(
                      stream: commentService.getComments(postId),
                      builder: (context, commentsSnapshot) {
                        if (commentsSnapshot.hasError) {
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: CustomText(
                              'Error loading comments',
                              style: TextStyle(color: Colors.red),
                            ),
                          );
                        }

                        final comments = commentsSnapshot.data ?? [];

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: Row(
                            children: [
                              GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LikesScreen(
                                          postId: documentId,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      CustomText(
                                        '$likesCount Like${likesCount == 1 ? "" : "s"}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Icon(Icons.arrow_forward_ios)
                                    ],
                                  )),
                              Spacer(),
                              CustomText(
                                '${comments.length} Comment${comments.length == 1 ? "" : "s"}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
                const Divider(height: 1),

                // List of Comments
                Expanded(
                  child: StreamBuilder<List<CommentsModel>>(
                    stream: commentService.getComments(postId),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: CustomText(
                            'Error loading comments',
                            style: TextStyle(color: Colors.red),
                          ),
                        );
                      }

                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      final comments = snapshot.data!;

                      if (comments.isEmpty) {
                        return const Center(
                          child: CustomText(
                            'No comments yet. Be the first to comment!',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        );
                      }

                      return ListView.separated(
                        separatorBuilder: (context, index) {
                          return Divider(color: Colors.grey[400]);
                        },
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 5.0,
                        ),
                        itemCount: comments.length,
                        itemBuilder: (BuildContext context, int index) {
                          final CommentsModel currentComment = comments[index];
                          final currentUser = AuthService().currentUser;
                          final isCommentOwner =
                              currentUser?.uid == currentComment.userId;

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8.0,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Colors.grey[300],
                                  backgroundImage:
                                      (currentComment.userImgUrl.isNotEmpty)
                                          ? NetworkImage(
                                              currentComment.userImgUrl,
                                            )
                                          : null,
                                  child: (currentComment.userImgUrl.isEmpty)
                                      ? const Icon(
                                          Icons.person,
                                          size: 25,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: CustomText(
                                              currentComment.username,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      CustomText(
                                        currentComment.comment,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      CustomText(
                                        _getTimeAgo(currentComment.timestamp),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isCommentOwner)
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Delete Comment'),
                                          content: const Text(
                                              'Are you sure you want to delete this comment?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () async {
                                                try {
                                                  await commentService
                                                      .deleteComment(
                                                    postId: postId,
                                                    userId: currentUser!.uid,
                                                    timestamp: currentComment
                                                        .timestamp,
                                                  );
                                                  if (context.mounted) {
                                                    Navigator.pop(context);
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                            'Comment deleted successfully'),
                                                      ),
                                                    );
                                                  }
                                                } catch (e) {
                                                  if (context.mounted) {
                                                    Navigator.pop(context);
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                            'Failed to delete comment: ${e.toString()}'),
                                                        backgroundColor:
                                                            Colors.red,
                                                      ),
                                                    );
                                                  }
                                                }
                                              },
                                              child: Text(
                                                'Delete',
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .error,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(modalContext).viewInsets.bottom + 10,
                    left: 16.0,
                    right: 16.0,
                    top: 8.0,
                  ),
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      hintText: 'Add comment',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () {
                          if (controller.text.trim().isNotEmpty) {
                            onCommentSent(controller.text.trim());
                            controller.clear();
                          }
                        },
                      ),
                    ),
                    onFieldSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        onCommentSent(value.trim());
                        controller.clear();
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
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
