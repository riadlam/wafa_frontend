import 'package:flutter/material.dart';

class DistanceBadge extends StatelessWidget {
  final String distance;
  
  const DistanceBadge({
    Key? key,
    required this.distance,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.location_on,
            color: Colors.white,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            '$distance away',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
