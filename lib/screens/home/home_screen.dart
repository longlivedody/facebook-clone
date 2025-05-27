import 'package:facebook_clone/models/user_data_model.dart';
import 'package:facebook_clone/screens/home/home_item.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<PostDataModel> _posts = PostDataModel.posts;

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
                  child: ListView.separated(
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
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
