import 'package:facebook_clone/models/user_data_model.dart';
import 'package:facebook_clone/screens/home/home_item.dart';
import 'package:flutter/material.dart';

// You'll create this file next
import 'home_shimmer_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {},
                  child: _isLoading ? _buildShimmerList() : _buildPostsList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostsList() {
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
            Divider(color: Theme.of(context).dividerColor),
            const SizedBox(height: 10),
          ],
        );
      },
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        final post = _posts[index];
        return HomeItem(postData: post);
      },
    );
  }

  Widget _buildShimmerList() {
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
      itemCount: 5, // Display a few shimmer items
      itemBuilder: (context, index) {
        return const HomeShimmerItem();
      },
    );
  }
}
