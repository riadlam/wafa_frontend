import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CategoryGridSkeleton extends StatelessWidget {
  final int itemCount;
  final double aspectRatio;
  final double spacing;
  final int crossAxisCount;

  const CategoryGridSkeleton({
    super.key,
    this.itemCount = 6,
    this.aspectRatio = 1.1,
    this.spacing = 16.0,
    this.crossAxisCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: spacing, vertical: 8.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: aspectRatio,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
        ),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 8.0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon placeholder
                  Container(
                    width: 32.0,
                    height: 32.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  // Title placeholder
                  Container(
                    width: 80,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  // Subtitle placeholder
                  Container(
                    width: 60,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
