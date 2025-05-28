import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class HomeShimmerItem extends StatelessWidget {
  const HomeShimmerItem({super.key});

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
          // User Section Placeholder
          Row(
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
          ),
          const SizedBox(height: 10),

          // Post Text Placeholder
          Container(width: double.infinity, height: 14, color: Colors.white),
          const SizedBox(height: 4),
          Container(width: screenWidth * 0.7, height: 14, color: Colors.white),
          const SizedBox(height: 10),

          // Post Image Placeholder
          Container(
            width: double.infinity,
            height: estimatedImageHeight,
            color: Colors.white,
          ),
          const SizedBox(height: 10),

          // Reacts/Comments/Shares Placeholder
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(width: 60, height: 12, color: Colors.white),
              Container(width: 80, height: 12, color: Colors.white),
              Container(width: 70, height: 12, color: Colors.white),
            ],
          ),
          const SizedBox(height: 15),

          // Actions Section Placeholder
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            // Adjust to match original
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildActionPlaceholder(),
                _buildActionPlaceholder(),
                _buildActionPlaceholder(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionPlaceholder() {
    return Row(
      children: [
        Container(width: 24, height: 24, color: Colors.white),
        // Icon placeholder
        const SizedBox(width: 5),
        Container(width: 50, height: 12, color: Colors.white),
        // Text placeholder
      ],
    );
  }
}
