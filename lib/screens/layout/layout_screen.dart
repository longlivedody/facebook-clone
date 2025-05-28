import 'package:facebook_clone/models/video_model.dart';
import 'package:facebook_clone/screens/reels/reels_screen.dart';
import 'package:facebook_clone/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';

import '../posts/posts_screen.dart';

class LayoutScreen extends StatelessWidget {
  const LayoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
            child: Column(
              children: [
                CustomAppbar(),
                const TabBar(
                  tabs: [
                    Tab(icon: Icon(Icons.home, size: 35)),
                    Tab(icon: Icon(Icons.ondemand_video, size: 35)),
                    Tab(icon: Icon(Icons.notifications, size: 35)),
                    Tab(icon: Icon(Icons.menu, size: 35)),
                  ],

                  labelColor: Colors.blue,
                  // Or your app's primary color
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.blue,
                  // Or your app's primary color
                  indicatorSize: TabBarIndicatorSize.tab,
                ),
                // 3. Add the TabBarView
                Expanded(
                  // Important to make TabBarView fill available space
                  child: TabBarView(
                    children: [
                      // Content for Tab 1 (Home)
                      PostsScreen(),
                      // Content for Tab 2 (videos)
                      ReelsScreen(videos: sampleVideos),
                      // Content for Tab 3 (notifications)
                      Center(child: Text('notifications Content')),
                      // Content for Tab 4 (Alerts)
                      Center(child: Text('menu Content')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
