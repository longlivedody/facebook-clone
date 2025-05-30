import 'package:flutter/material.dart';

// You'll create this file next
import '../../models/post_data_model.dart';
import 'post_item.dart';
import 'post_shimmer_item.dart';
import 'create_post_screen.dart';
import 'package:facebook_clone/services/auth_services/auth_service.dart';
import 'package:facebook_clone/services/post_services/create_post_service.dart';
import 'package:facebook_clone/widgets/custom_text.dart';

/// A screen that displays a list of posts with pull-to-refresh functionality
/// and the ability to create new posts.
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

  /// Initializes the posts by checking the connection and loading data
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

  /// Navigates to the create post screen
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

  /// Refreshes the posts list
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
                  child: _isLoading ? _buildShimmerList() : _buildPostsList(),
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

  /// Builds the main posts list with error handling and empty state
  Widget _buildPostsList() {
    if (!_isConnected) {
      return _buildErrorView(
        icon: Icons.cloud_off,
        message: _error ?? 'No connection',
        color: Colors.grey,
      );
    }

    return StreamBuilder<List<PostDataModel>>(
      stream: _postService.getPosts(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorView(
            icon: Icons.error_outline,
            message: 'Error: ${snapshot.error}',
            color: Colors.red,
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final posts = snapshot.data!;
        if (posts.isEmpty) {
          return const Center(
            child: CustomText('No posts yet. Be the first to post!'),
          );
        }

        return _buildPostsListView(posts);
      },
    );
  }

  /// Builds a list view of posts with separators
  Widget _buildPostsListView(List<PostDataModel> posts) {
    return ListView.separated(
      separatorBuilder: _buildSeparator,
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) => PostItem(postData: posts[index]),
    );
  }

  /// Builds a shimmer loading list
  Widget _buildShimmerList() {
    return ListView.separated(
      separatorBuilder: _buildSeparator,
      itemCount: 3,
      itemBuilder: (_, __) => const PostShimmerItem(),
    );
  }

  /// Builds a separator widget for the list
  Widget _buildSeparator(BuildContext context, int index) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Divider(
          color: Theme.of(context).dividerColor.withAlpha(50),
        ),
        const SizedBox(height: 5),
      ],
    );
  }

  /// Builds an error view with icon, message and retry button
  Widget _buildErrorView({
    required IconData icon,
    required String message,
    required Color color,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: color),
          const SizedBox(height: 16),
          CustomText(
            message,
            style: TextStyle(color: color),
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

  @override
  bool get wantKeepAlive => true;
}
