import 'package:flutter/material.dart';
import 'package:loyaltyapp/constants/colors.dart';
import 'package:loyaltyapp/constants/typography.dart';

class ActivityItem {
  final String title;
  final String time;
  final IconData icon;
  final Color color;

  ActivityItem({
    required this.title,
    required this.time,
    required this.icon,
    required this.color,
  });
}

class RecentActivityList extends StatelessWidget {
  RecentActivityList({super.key});

  final List<ActivityItem> activities = [
    ActivityItem(
      title: 'New order #1234 received',
      time: '2 min ago',
      icon: Icons.shopping_bag_outlined,
      color: AppColors.primary,
    ),
    ActivityItem(
      title: 'Payment received from John Doe',
      time: '1 hour ago',
      icon: Icons.payment_outlined,
      color: AppColors.success,
    ),
    ActivityItem(
      title: 'New customer registered',
      time: '3 hours ago',
      icon: Icons.person_add_alt_1_outlined,
      color: AppColors.info,
    ),
    ActivityItem(
      title: 'Low stock alert: Product #456',
      time: '5 hours ago',
      icon: Icons.warning_amber_rounded,
      color: AppColors.warning,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activity',
                  style: AppTextStyles.subtitle1.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(50, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'View All',
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.primary,
                      fontSize: 12,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activities.length,
              separatorBuilder: (context, index) => const Divider(height: 24),
              itemBuilder: (context, index) {
                final activity = activities[index];
                return _buildActivityItem(activity);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(ActivityItem activity) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: activity.color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            activity.icon,
            size: 18,
            color: activity.color,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                activity.title,
                style: AppTextStyles.bodyText2.copyWith(
                  color: AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                activity.time,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
