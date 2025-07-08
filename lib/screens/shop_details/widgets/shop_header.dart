import 'package:flutter/material.dart';

class ShopHeader extends StatelessWidget {
  final String shopName;
  final String category;
  final String? heroTag;

  const ShopHeader({
    super.key,
    required this.shopName,
    required this.category,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shop name and category
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: heroTag ?? shopName,
                  child: Material(
                    type: MaterialType.transparency,
                    child: Text(
                      shopName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  category,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Share button
          GestureDetector(
            onTap: () {
              // Implement share logic
            },
            child: Image.asset(
              'assets/images/sharebutton.png',
              width: 30,
              height: 30,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
