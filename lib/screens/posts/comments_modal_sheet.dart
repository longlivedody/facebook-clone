import 'package:flutter/material.dart';

import '../../models/comments_model.dart';
import '../../widgets/custom_text.dart';

void showCommentsModal({
  required BuildContext context,
  required List<CommentsModel> comments,
  required TextEditingController controller,
  required Function(String) onCommentSent,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
    ),
    builder: (BuildContext modalContext) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
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
                      // A slightly darker grey for visibility
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                // Comments Count Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: CustomText(
                    '${comments.length} Comment${comments.length == 1 ? "" : "s"}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(height: 1),
                // Visual separator

                // List of Comments
                Expanded(
                  child: comments.isEmpty
                      ? const Center(
                          child: CustomText(
                            'No comments yet. Be the first to comment!',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        )
                      : ListView.separated(
                          separatorBuilder: (context, index) {
                            return Divider(color: Colors.grey[400]);
                          },
                          controller: scrollController,
                          // Important for DraggableScrollableSheet
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10.0,
                            vertical: 5.0,
                          ),
                          itemCount: comments.length,
                          itemBuilder: (BuildContext context, int index) {
                            final CommentsModel currentComment =
                                comments[index];
                            return Padding(
                              // Add some padding around each comment item
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
                                          ) // Show icon if URL is bad
                                        : null, // No child if backgroundImage is expected to load
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CustomText(
                                          currentComment.username,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        CustomText(
                                          currentComment.comment,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        const SizedBox(height: 4),
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
                                ],
                              ),
                            );
                          },
                        ),
                ),

                Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(modalContext).viewInsets.bottom +
                        10, // Adjust for keyboard and some spacing
                    left: 16.0,
                    right: 16.0,
                    top: 8.0, // Spacing above the text field
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
