import 'package:flutter/material.dart';
import 'package:loyaltyapp/constants/colors.dart';
import 'package:loyaltyapp/constants/typography.dart';

class SalesData {
  final String day;
  final double sales;
  final double orders;

  SalesData(this.day, this.sales, this.orders);
}

class SalesChart extends StatelessWidget {
  SalesChart({super.key});

  final List<SalesData> chartData = [
    SalesData('Mon', 1800, 1200),
    SalesData('Tue', 2200, 1800),
    SalesData('Wed', 2500, 2000),
    SalesData('Thu', 3000, 2800),
    SalesData('Fri', 2700, 2500),
    SalesData('Sat', 3500, 3200),
    SalesData('Sun', 4000, 3800),
  ];

  double get maxSales => chartData.map((e) => e.sales).reduce((a, b) => a > b ? a : b);

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
                  'Sales Overview',
                  style: AppTextStyles.subtitle1.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'This Week',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: chartData.map((data) {
                  final heightFactor = data.sales / maxSales;
                  final height = 120 * heightFactor;
                  final height2 = 120 * (data.orders / maxSales);
                  
                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    height: height,
                                    margin: const EdgeInsets.symmetric(horizontal: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.7),
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(4),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '\$${(data.sales / 1000).toStringAsFixed(1)}K',
                                    style: AppTextStyles.caption,
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    height: height2,
                                    margin: const EdgeInsets.symmetric(horizontal: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.secondary.withOpacity(0.7),
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(4),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '\$${(data.orders / 1000).toStringAsFixed(1)}K',
                                    style: AppTextStyles.caption,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          data.day,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegend('Sales', AppColors.primary),
                const SizedBox(width: 16),
                _buildLegend('Orders', AppColors.secondary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
