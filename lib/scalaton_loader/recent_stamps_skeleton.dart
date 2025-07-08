import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class RecentStampsSkeleton extends StatelessWidget {
  final Color primaryColor;
  final Color darkTextColor;
  final Color lightTextColor;
  final int itemCount;

  const RecentStampsSkeleton({
    super.key,
    required this.primaryColor,
    required this.darkTextColor,
    required this.lightTextColor,
    this.itemCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Table Header Skeleton
          _buildHeaderSkeleton(),
          const SizedBox(height: 24),
          // Table Rows Skeleton
          ...List.generate(itemCount, (index) => _buildRowSkeleton()),
        ],
      ),
    );
  }

  Widget _buildHeaderSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: _buildShimmerContainer(height: 14, width: 80),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: _buildShimmerContainer(height: 14, width: 60),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: _buildShimmerContainer(height: 14, width: 40),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRowSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14.0),
      child: Row(
        children: [
          // Avatar Skeleton
          _buildShimmerContainer(
            width: 40,
            height: 40,
            isCircle: true,
            color: Colors.grey[300],
          ),
          const SizedBox(width: 12),
          // Customer Info Skeleton
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShimmerContainer(height: 14, width: 120),
                const SizedBox(height: 4),
                _buildShimmerContainer(height: 12, width: 80),
              ],
            ),
          ),
          // Stamps Count Skeleton
          Expanded(
            flex: 2,
            child: Center(
              child: _buildShimmerContainer(height: 20, width: 40),
            ),
          ),
          // Time Skeleton
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: _buildShimmerContainer(height: 14, width: 60),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerContainer({
    required double width,
    required double height,
    double radius = 4.0,
    bool isCircle = false,
    Color? color,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color ?? Colors.grey[300],
        borderRadius: isCircle ? null : BorderRadius.circular(radius),
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
      ),
    );
  }
}
