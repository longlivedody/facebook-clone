import 'package:flutter/material.dart';

// You'll create this file next
import '../../models/post_data_model.dart';
import 'post_item.dart';
import 'post_shimmer_item.dart';
import 'create_post_screen.dart';
import 'package:facebook_clone/services/auth_service.dart';
import 'package:facebook_clone/services/post_service.dart';
import 'package:facebook_clone/widgets/custom_text.dart';

class PostsScreen extends StatefulWidget {
  final User user;
  final AuthService authService;

  const PostsScreen({
    super.key,
    required this.user,
    required this.authService,
  });

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen>
    with AutomaticKeepAliveClientMixin {
  final PostService _postService = PostService();
  bool _isLoading = true;
  String? _error;
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _initializePosts();
  }

  Future<void> _initializePosts() async {
    try {
      // Check Firestore connection
      _isConnected = await _postService.checkConnection();

      if (mounted) {
        setState(() {
          _isLoading = false;
          if (!_isConnected) {
            _error =
                'Unable to connect to the server. Please check your internet connection.';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Failed to initialize: $e';
        });
      }
    }
  }

  void _navigateToCreatePost() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreatePostScreen(
          user: widget.user,
          postService: _postService,
        ),
      ),
    );
  }

  Future<void> _refreshPosts() async {
    setState(() {
      _error = null;
      _isLoading = true;
    });
    await _initializePosts();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshPosts,
                  child: _isLoading ? buildShimmerList() : buildPostsList(),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreatePost,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget buildPostsList() {
    if (!_isConnected) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            CustomText(
              _error ?? 'No connection',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshPosts,
              child: const CustomText('Try Again'),
            ),
          ],
        ),
      );
    }

    return StreamBuilder<List<PostDataModel>>(
      stream: _postService.getPosts(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                CustomText(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _refreshPosts,
                  child: const CustomText('Try Again'),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final posts = snapshot.data!;

        if (posts.isEmpty) {
          return const Center(
            child: CustomText('No posts yet. Be the first to post!'),
          );
        }

        return ListView.separated(
          separatorBuilder: (context, index) {
            return const Column(
              children: [
                SizedBox(height: 10),
                Divider(),
                SizedBox(height: 5),
              ],
            );
          },
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return PostItem(postData: post);
          },
        );
      },
    );
  }

  Widget buildShimmerList() {
    return ListView.separated(
      separatorBuilder: (context, index) {
        return Column(
          children: [
            const SizedBox(height: 10),
            Divider(
              color: Theme.of(context).dividerColor.withAlpha(50),
            ),
            const SizedBox(height: 10),
          ],
        );
      },
      itemCount: 3,
      itemBuilder: (context, index) {
        return const PostShimmerItem();
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
