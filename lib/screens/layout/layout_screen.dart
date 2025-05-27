import 'package:facebook_clone/models/video_model.dart';
import 'package:facebook_clone/screens/layout/reels_screen.dart';
import 'package:facebook_clone/widgets/custom_text.dart';
import 'package:flutter/material.dart';

import '../../widgets/custom_icon_button.dart';
import '../home/home_screen.dart';

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
                Row(
                  children: [
                    CustomText(
                      'facebook',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    CustomIconButton(
                      onPressed: () {},
                      iconData: Icons.add_circle,
                      iconSize: 30,
                    ),
                    CustomIconButton(
                      onPressed: () {},
                      iconData: Icons.search,
                      iconSize: 30,
                    ),
                    CustomIconButton(
                      onPressed: () {},
                      iconData: Icons.message,
                      iconSize: 30,
                    ),
                  ],
                ),

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
                      HomeScreen(),
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
