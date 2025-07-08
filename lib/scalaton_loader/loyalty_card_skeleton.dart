import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoyaltyCardSkeleton extends StatelessWidget {
  final int itemCount;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const LoyaltyCardSkeleton({
    super.key,
    this.itemCount = 3,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        shrinkWrap: shrinkWrap,
        physics: physics,
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _SkeletonBox(width: 50, height: 50, radius: 8.0),
                      SizedBox(width: 12.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SkeletonBox(width: 120, height: 16, radius: 4.0),
                            SizedBox(height: 6.0),
                            _SkeletonBox(width: 80, height: 14, radius: 4.0),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  _SkeletonBox(height: 12, radius: 4.0),
                  SizedBox(height: 8.0),
                  _SkeletonBox(height: 8, radius: 4.0),
                  SizedBox(height: 8.0),
                  _SkeletonBox(width: 200, height: 8, radius: 4.0),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double radius;

  const _SkeletonBox({
    this.width,
    this.height,
    this.radius = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
