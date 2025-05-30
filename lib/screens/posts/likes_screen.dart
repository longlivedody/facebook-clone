import 'package:facebook_clone/widgets/custom_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../widgets/custom_text.dart';

class LikesScreen extends StatelessWidget {
  final String postId;

  const LikesScreen({
    super.key,
    required this.postId,
  });

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Likes Count Header
            Row(
              children: [
                CustomIconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    iconData: Icons.arrow_back_ios),
                StreamBuilder<DocumentSnapshot>(
                  stream:
                      _firestore.collection('posts').doc(postId).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: CustomText(
                          'Error loading likes',
                          style: TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final postData =
                        snapshot.data!.data() as Map<String, dynamic>;
                    final likesCount = postData['likesCount'] ?? 0;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: CustomText(
                        '$likesCount Like${likesCount == 1 ? "" : "s"}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                )
              ],
            ),
            const Divider(height: 1),

            // List of Likes
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('likes')
                    .where('postId', isEqualTo: postId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: CustomText(
                        'Error loading likes',
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
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
                    separatorBuilder: (context, index) {
                      return Divider();
                    },
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 5.0,
                    ),
                    itemCount: likes.length,
                    itemBuilder: (BuildContext context, int index) {
                      final like = likes[index].data() as Map<String, dynamic>;
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
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
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
