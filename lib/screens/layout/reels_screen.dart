import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../models/video_model.dart';

class ReelsScreen extends StatefulWidget {
  final List<VideoInfo> videos;

  const ReelsScreen({super.key, required this.videos});

  @override
  ReelsScreenState createState() => ReelsScreenState();
}

String _formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);

  if (hours > 0) {
    return "${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}";
  } else {
    return "${twoDigits(minutes)}:${twoDigits(seconds)}";
  }
}

late PageController _pageController;
Map<int, VideoPlayerController> _videoControllers = {};
Map<int, Future<void>> _initializeVideoPlayerFutures = {};
int _currentPage = 0;

class ReelsScreenState extends State<ReelsScreen> {
  // ... (rest of your existing state variables)

  // No need for new state variables just for displaying duration/position
  // if we read directly from controller.value in the build method.
  // However, if you need to react to position changes for other logic,
  // you would add listeners in _initializeAndPlay.

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initializeAndPlay(0);
  }

  void _initializeAndPlay(int index) {
    if (widget.videos.isEmpty || index < 0 || index >= widget.videos.length) {
      return;
    }

    if (_videoControllers.containsKey(_currentPage) && _currentPage != index) {
      _videoControllers[_currentPage]?.removeListener(
        _onControllerUpdate,
      ); // Remove listener from old
      _videoControllers[_currentPage]?.pause();
    }

    final videoUrl = widget.videos[index].videoUrl;
    // Dispose existing controller for the same index if we are re-initializing
    _videoControllers[index]?.dispose();

    final controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
    _videoControllers[index] = controller;
    // Add a listener to rebuild UI when position changes
    controller.addListener(_onControllerUpdate);

    _initializeVideoPlayerFutures[index] = controller
        .initialize()
        .then((_) {
          if (mounted) {
            // Check if widget is still in the tree
            setState(() {}); // Update UI to show duration, first frame etc.
            if (_currentPage == index) {
              controller.play();
              controller.setLooping(true);
            }
          }
        })
        .catchError((error) {
          debugPrint("Error initializing video at index $index: $error");
          if (mounted) {
            setState(() {});
          }
        });
  }

  // Listener to update UI on controller changes (like position)
  void _onControllerUpdate() {
    if (!mounted) {
      return;
    }
    // This will trigger a rebuild if the currently active video's controller updates.
    // We only want to rebuild if the update is for the _currentPage.
    // A more robust way is to check which controller is updating if you have multiple listeners.
    // For simplicity here, we just call setState.
    setState(() {});
  }

  @override
  void dispose() {
    _pageController.dispose();
    _videoControllers.forEach((index, controller) {
      controller.removeListener(
        _onControllerUpdate,
      ); // Important: remove listeners
      controller.dispose();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.videos.isEmpty) {
      return const Center(child: Text("No videos to display."));
    }

    return Scaffold(
      backgroundColor: Colors.black, // Common for video players
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: widget.videos.length,
        onPageChanged: (index) {
          // Pause previous video
          final previousPageIndex = _currentPage;
          _videoControllers[previousPageIndex]?.pause();
          // It's good practice to remove listener from the controller that is no longer current
          // if you are adding listeners selectively. However, our _onControllerUpdate is generic.

          setState(() {
            _currentPage = index;
          });

          // Initialize and play the new current video
          if (!_videoControllers.containsKey(index) ||
              !_videoControllers[index]!.value.isInitialized) {
            _initializeAndPlay(index);
          } else {
            _videoControllers[index]?.play();
            _videoControllers[index]?.setLooping(true);
          }
        },
        itemBuilder: (context, index) {
          return FutureBuilder(
            future: _initializeVideoPlayerFutures[index],
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  _videoControllers[index] != null &&
                  _videoControllers[index]!.value.isInitialized) {
                final controller = _videoControllers[index]!;
                // Get duration and position
                final Duration duration = controller.value.duration;
                final Duration position = controller.value.position;

                return Stack(
                  // Use Stack to overlay text on video
                  alignment: Alignment.bottomCenter, // Align text to bottom
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (controller.value.isPlaying) {
                          controller.pause();
                        } else {
                          controller.play();
                        }
                        // setState is called by _onControllerUpdate or can be called here too
                        // if _onControllerUpdate is not set up for play/pause state changes.
                      },
                      child: SizedBox.expand(
                        child: FittedBox(
                          fit: BoxFit.fill,
                          clipBehavior: Clip.hardEdge,
                          child: SizedBox(
                            width: controller.value.size.width,
                            height: controller.value.size.height,
                            child: VideoPlayer(controller),
                          ),
                        ),
                      ),
                    ),
                    // Video Progress Indicator (optional, but good for UX)
                    VideoProgressIndicator(
                      controller,
                      allowScrubbing: true,
                      padding: const EdgeInsets.all(16.0),
                      colors: const VideoProgressColors(
                        playedColor: Colors.red,
                        bufferedColor: Colors.grey,
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                    // Display Duration and Position
                    Positioned(
                      bottom: 40, // Adjust position as needed
                      left: 16,
                      right: 16,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(position),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              shadows: <Shadow>[
                                Shadow(
                                  offset: Offset(0.0, 1.0),
                                  blurRadius: 3.0,
                                  color: Color.fromARGB(150, 0, 0, 0),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            _formatDuration(duration),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              shadows: <Shadow>[
                                Shadow(
                                  offset: Offset(0.0, 1.0),
                                  blurRadius: 3.0,
                                  color: Color.fromARGB(150, 0, 0, 0),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Example: Play/Pause button overlay
                    if (!controller.value.isPlaying)
                      Center(
                        child: IconButton(
                          icon: Icon(
                            controller.value.isPlaying
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_filled,
                            color: Colors.white.withAlpha(70),
                            size: 60,
                          ),
                          onPressed: () {
                            if (controller.value.isPlaying) {
                              controller.pause();
                            } else {
                              controller.play();
                            }
                            // setState will be called by _onControllerUpdate
                          },
                        ),
                      ),
                  ],
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Error loading video",
                        style: TextStyle(color: Colors.red),
                      ),
                      Text(
                        widget.videos[index].title,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                // Show a loading indicator while the video is preparing
                return const Center(child: CircularProgressIndicator());
              }
            },
          );
        },
      ),
    );
  }
}
