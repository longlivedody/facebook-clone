import 'package:facebook_clone/models/post_data_model.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

import '../../widgets/custom_text.dart';
import 'comments_modal_sheet.dart';

class PostItem extends StatelessWidget {
  final PostDataModel postData;

  const PostItem({super.key, required this.postData});

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
          postTime: postData.postTime.toString(),
        ),
        const SizedBox(height: 10),
        // post content
        CustomText(postData.postText),
        const SizedBox(height: 10),
        // post image
        if (postData.postImageUrl.isNotEmpty)
          FadeInImage.memoryNetwork(
            placeholder: kTransparentImage,
            image: postData.postImageUrl,
            width: double.infinity,
            fit: BoxFit.fill,
            height: estimatedImageHeight,
          ),
        const SizedBox(height: 10),
        // likes , comment and shares
        GestureDetector(
          onTap: () {
            showCommentsModal(
              context: context,
              comments: postData.comments,
              controller: controller,
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
}

Widget userSection({
  required String username,
  required String profileImageUrl,
  required String postTime,
}) {
  return Row(
    children: [
      CircleAvatar(radius: 27, backgroundImage: NetworkImage(profileImageUrl)),
      const SizedBox(width: 8),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            username,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          CustomText(postTime, style: TextStyle(fontSize: 12)),
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
        CustomText('$likesCount likes', style: TextStyle(fontSize: 12)),
        CustomText('$commentsCount comments', style: TextStyle(fontSize: 12)),
        CustomText('$sharesCount shares', style: TextStyle(fontSize: 12)),
      ],
    ),
  );
}

Widget actionsSection() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 25.0),
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
