import 'package:flutter/material.dart';
import 'package:loyaltyapp/constants/colors.dart';
import 'package:loyaltyapp/constants/typography.dart';

class QuickActionItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  QuickActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

class QuickActionsCard extends StatelessWidget {
  QuickActionsCard({super.key});

  final List<QuickActionItem> actions = [
    QuickActionItem(
      icon: Icons.add_circle_outline,
      label: 'Add Product',
      onTap: () {},
    ),
    QuickActionItem(
      icon: Icons.person_add_alt_1_outlined,
      label: 'Add Customer',
      onTap: () {},
    ),
    QuickActionItem(
      icon: Icons.receipt_long_outlined,
      label: 'New Order',
      onTap: () {},
    ),
    QuickActionItem(
      icon: Icons.analytics_outlined,
      label: 'View Reports',
      onTap: () {},
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
            Text(
              'Quick Actions',
              style: AppTextStyles.subtitle1.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.5,
              ),
              itemCount: actions.length,
              itemBuilder: (context, index) {
                final action = actions[index];
                return _buildActionButton(action);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(QuickActionItem action) {
    return OutlinedButton(
      onPressed: action.onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(action.icon, size: 20),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              action.label,
              style: AppTextStyles.bodyText2.copyWith(
                color: AppColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
