// In your models/post_data_model.dart

import 'comments_model.dart'; // Make sure this import is correct

class PostDataModel {
  final int postId;
  final String username;
  final String profileImageUrl;
  final String postText;
  final String postImageUrl;
  final String postTime;
  final int likesCount;

  final int sharesCount;
  final List<CommentsModel> comments;

  PostDataModel({
    required this.postId,
    required this.username,
    required this.profileImageUrl,
    required this.postText,
    required this.postImageUrl,
    required this.likesCount,
    required this.sharesCount,
    required this.postTime,
    required this.comments,
  });

  int get commentsCount => comments.length;

  static final List<PostDataModel> posts = [
    PostDataModel(
      postId: 0,
      username: "Mahmoud Magdy",
      profileImageUrl: "https://picsum.photos/seed/user1/50/50",
      postText: "Having a great time exploring Flutter! #FlutterDev",
      postImageUrl: "",
      likesCount: 1520,
      sharesCount: 35,
      postTime: '5:39 PM',
      comments: [CommentsModel.comments[0], CommentsModel.comments[2]],
    ),
    PostDataModel(
      postId: 1,
      username: "Jane Doe",
      profileImageUrl: "https://picsum.photos/seed/user2/50/50",
      postText: "Just launched my new app. Check it out!",
      postImageUrl: "https://picsum.photos/seed/post2/600/400",
      likesCount: 2100,
      sharesCount: 50,
      postTime: '2:21 PM',
      comments: [
        CommentsModel.comments[1],
        CommentsModel.comments[3],
        CommentsModel.comments[4],
      ],
    ),
    PostDataModel(
      postId: 2,
      username: "Alex Smith",
      profileImageUrl: "https://picsum.photos/seed/user3/50/50",
      postText:
          "Learning about state management in Flutter. It's quite interesting.",
      postImageUrl: "https://picsum.photos/seed/post3/600/400",
      likesCount: 950,
      sharesCount: 15,
      postTime: '12:21 AM',
      comments: [],
    ),
    PostDataModel(
      postId: 3,
      username: "Sarah Lee",
      profileImageUrl: "https://picsum.photos/seed/user4/50/50",
      postText: "Enjoying a beautiful sunset. #NaturePhotography",
      postImageUrl: "https://picsum.photos/seed/post4/600/400",
      likesCount: 1800,
      sharesCount: 40,
      postTime: '2:21 PM',
      comments: [
        CommentsModel(
          userImgUrl:
              'https://cdn.pixabay.com/photo/2020/06/30/10/23/icon-5355896_1280.png',
          username: 'AliceWonder',
          comment: 'Great article! Really enjoyed the insights.',
        ),
        CommentsModel(
          userImgUrl:
              'https://cdn.pixabay.com/photo/2020/06/30/10/23/icon-5355896_1280.png',
          username: 'BobTheBuilder',
          comment: 'This was very helpful, thank you for sharing.',
        ),
      ],
    ),
  ];
}
