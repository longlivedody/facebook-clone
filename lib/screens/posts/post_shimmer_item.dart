import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// A shimmer loading placeholder widget that mimics the structure of a post item.
/// This widget is used to show a loading state while the actual post content is being fetched.
class PostShimmerItem extends StatelessWidget {
  const PostShimmerItem({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final estimatedImageHeight = screenWidth * (9 / 16);

    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserSection(),
          const SizedBox(height: 10),
          _buildPostTextSection(screenWidth),
          const SizedBox(height: 10),
          _buildPostImageSection(estimatedImageHeight),
          const SizedBox(height: 10),
          _buildStatsSection(),
          const SizedBox(height: 15),
          _buildActionsSection(),
        ],
      ),
    );
  }

  /// Builds the user section with avatar and name placeholders
  Widget _buildUserSection() {
    return Row(
      children: [
        const CircleAvatar(radius: 27),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 120, height: 16, color: Colors.white),
            const SizedBox(height: 4),
            Container(width: 80, height: 12, color: Colors.white),
          ],
        ),
      ],
    );
  }

  /// Builds the post text section with placeholder lines
  Widget _buildPostTextSection(double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(width: double.infinity, height: 14, color: Colors.white),
        const SizedBox(height: 4),
        Container(width: screenWidth * 0.7, height: 14, color: Colors.white),
      ],
    );
  }

  /// Builds the post image placeholder
  Widget _buildPostImageSection(double height) {
    return Container(
      width: double.infinity,
      height: height,
      color: Colors.white,
    );
  }

  /// Builds the stats section (reactions, comments, shares)
  Widget _buildStatsSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(width: 60, height: 12, color: Colors.white),
        Container(width: 80, height: 12, color: Colors.white),
        Container(width: 70, height: 12, color: Colors.white),
      ],
    );
  }

  /// Builds the actions section with placeholders for like, comment, and share
  Widget _buildActionsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(3, (_) => _buildActionPlaceholder()),
      ),
    );
  }

  /// Builds a single action placeholder with icon and text
  Widget _buildActionPlaceholder() {
    return Row(
      children: [
        Container(width: 24, height: 24, color: Colors.white),
        const SizedBox(width: 5),
        Container(width: 50, height: 12, color: Colors.white),
      ],
    );
  }
}
