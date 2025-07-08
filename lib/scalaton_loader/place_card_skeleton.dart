import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class PlaceCardSkeleton extends StatelessWidget {
  final int itemCount;
  final double spacing;

  const PlaceCardSkeleton({
    super.key,
    this.itemCount = 3,
    this.spacing = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 24),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(bottom: spacing),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image placeholder (reduced by 10% from original)
                Container(
                  height: 144, // Reduced from 160 (10% of 160 is 16, 160-16=144)
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16.0),
                    ),
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(14.4), // Reduced padding by 10% (16 * 0.9)
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Container(
                        width: 200,
                        height: 16.2, // Reduced by 10% (18 * 0.9)
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      ),
                      const SizedBox(height: 7.2), // Reduced by 10%
                      // Subtitle
                      Container(
                        width: 150,
                        height: 14.4, // Reduced by 10% (16 * 0.9)
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      ),
                      const SizedBox(height: 14.4), // Reduced by 10%
                      // Rating and distance row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Rating
                          Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4.0),
                              Container(
                                width: 30,
                                height: 14,
                                color: Colors.white,
                              ),
                            ],
                          ),
                          // Distance
                          Container(
                            width: 80,
                            height: 14,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
