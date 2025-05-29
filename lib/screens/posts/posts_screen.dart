import 'package:flutter/material.dart';

// You'll create this file next
import '../../models/post_data_model.dart';
import 'post_item.dart';
import 'post_shimmer_item.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen>
    with AutomaticKeepAliveClientMixin {
  List<PostDataModel> _posts = []; // Initialize as empty
  bool _isLoading = true; // Start in loading state

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    // Simulate network delay
    _posts = PostDataModel.posts; // Load your static posts for now

    await Future.delayed(const Duration(seconds: 2));

    // In a real app, replace this with your actual data fetching logic
    setState(() {
      _isLoading = false;
    });
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
                  onRefresh: () async {
                    await _fetchPosts();
                  },
                  child: _isLoading ? buildShimmerList() : buildPostsList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPostsList() {
    if (_posts.isEmpty) {
      return const Center(
        child: Text("No posts yet. Pull to refresh!"),
      ); // Or some other empty state
    }
    return ListView.separated(
      separatorBuilder: (context, index) {
        return Column(
          children: [
            const SizedBox(height: 10),
            Divider(),
            const SizedBox(height: 5),
          ],
        );
      },
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        final post = _posts[index];
        return PostItem(postData: post);
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
            ), // Lighter divider for shimmer
            const SizedBox(height: 10),
          ],
        );
      },
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        return const PostShimmerItem();
      },
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
