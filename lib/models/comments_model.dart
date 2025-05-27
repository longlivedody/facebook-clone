class CommentsModel {
  final String userImgUrl;
  final String username;
  final String comment;

  CommentsModel({
    required this.userImgUrl,
    required this.username,
    required this.comment,
  });

  // Sample comments, now with postId
  static final List<CommentsModel> comments = [
    CommentsModel(
      userImgUrl:
          'https://media.istockphoto.com/id/1389665844/photo/happy-young-woman-standing-next-to-her-metaverse-avatar.jpg?s=2048x2048&w=is&k=20&c=SLrysQ5LNe8HFeEs_9vRb6zOuuTQvv3Dbdec8fbepOI=',
      username: 'AliceWonder',
      comment: 'Great article! Really enjoyed the insights.',
    ),
    CommentsModel(
      userImgUrl:
          'https://cdn.pixabay.com/photo/2016/12/07/21/01/cartoon-1890438_1280.jpg',
      username: 'BobTheBuilder',
      comment: 'This was very helpful, thank you for sharing.',
    ),
    CommentsModel(
      userImgUrl:
          'https://media.istockphoto.com/id/1389665844/photo/happy-young-woman-standing-next-to-her-metaverse-avatar.jpg?s=2048x2048&w=is&k=20&c=SLrysQ5LNe8HFeEs_9vRb6zOuuTQvv3Dbdec8fbepOI=',
      username: 'CharlieCode',
      comment:
          'I have a question regarding the second point. Can you elaborate?',
    ),
    CommentsModel(
      userImgUrl:
          'https://cdn.pixabay.com/photo/2020/06/30/10/23/icon-5355896_1280.png',
      username: 'DianaDev',
      comment: 'Awesome work! Looking forward to more content like this.',
    ),
    CommentsModel(
      userImgUrl:
          'https://cdn.pixabay.com/photo/2016/12/07/21/01/cartoon-1890438_1280.jpg',
      username: 'EddieExplorer',
      comment: 'Could you provide a link to the source code mentioned?',
    ),
  ];
}
