import 'package:flutter/material.dart';
import 'package:loyaltyapp/constants/colors.dart';
import 'package:loyaltyapp/constants/typography.dart';

class LoyaltyStats extends StatelessWidget {
  final int totalSubscribers;
  final int totalRedemptions;
  final double redemptionRate;
  final List<Map<String, dynamic>> recentRedemptions;

  const LoyaltyStats({
    super.key,
    required this.totalSubscribers,
    required this.totalRedemptions,
    required this.redemptionRate,
    required this.recentRedemptions,
  });

  @override
  Widget build(BuildContext context) {    
    return Container();
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTextStyles.headline4.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title.toUpperCase(),
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary.withOpacity(0.8),
                  fontSize: 11,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRedemptionsTable({bool isMobile = false}) {
    if (recentRedemptions.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 32),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.redeem_outlined, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              'No recent redemptions',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'When customers redeem rewards, they\'ll appear here',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (isMobile) {
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: recentRedemptions.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final redemption = recentRedemptions[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      redemption['customerName'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(redemption['status']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        redemption['status'] ?? '',
                        style: TextStyle(
                          color: _getStatusColor(redemption['status']),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  redemption['rewardName'] ?? '',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  redemption['date'] ?? '',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[100]!),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Theme(
          data: ThemeData.light().copyWith(
            dividerColor: Colors.grey[100],
            dataTableTheme: DataTableThemeData(
              headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
              dataRowMinHeight: 56,
              dataRowMaxHeight: 56,
            ),
          ),
          child: DataTable(
            headingTextStyle: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
              fontSize: 13,
              letterSpacing: 0.2,
            ),
            dataTextStyle: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
            ),
            columnSpacing: 32,
            horizontalMargin: 16,
            columns: const [
              DataColumn(label: Text('CUSTOMER')),
              DataColumn(label: Text('REWARD')),
              DataColumn(label: Text('DATE')),
              DataColumn(label: Text('STATUS')),
            ],
            rows: recentRedemptions.map((redemption) {
              return DataRow(
                cells: [
                  DataCell(Text(
                    redemption['customerName'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  )),
                  DataCell(Text(redemption['rewardName'] ?? '')),
                  DataCell(Text(redemption['date'] ?? '')),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(redemption['status']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getStatusColor(redemption['status']).withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        (redemption['status'] ?? '').toUpperCase(),
                        style: TextStyle(
                          color: _getStatusColor(redemption['status']),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  static Color _getStatusColor(String? status) {
    if (status == null) return AppColors.textSecondary;
    switch (status.toLowerCase()) {
      case 'completed':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}
