import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loyaltyapp/models/stamp_activation_model.dart';
import 'package:loyaltyapp/services/stamp_service.dart';
import 'package:loyaltyapp/scalaton_loader/recent_stamps_skeleton.dart';

class RecentStampsTable extends StatefulWidget {
  final Color primaryColor;
  final Color darkTextColor;
  final Color lightTextColor;

  const RecentStampsTable({
    super.key,
    required this.primaryColor,
    required this.darkTextColor,
    required this.lightTextColor,
  });

  @override
  State<RecentStampsTable> createState() => _RecentStampsTableState();
}

class _RecentStampsTableState extends State<RecentStampsTable> {
  late Future<List<StampActivation>> _stampsFuture;
  final StampService _stampService = StampService();

  @override
  void initState() {
    super.initState();
    _loadStamps();
  }

  void _loadStamps() {
    setState(() {
      _stampsFuture = _stampService.getRecentStamps();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<StampActivation>>(
      future: _stampsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return RecentStampsSkeleton(
            primaryColor: widget.primaryColor,
            darkTextColor: widget.darkTextColor,
            lightTextColor: widget.lightTextColor,
          );
        } else if (snapshot.hasError) {
          return Column(
            children: [
              Text('Error: ${snapshot.error}'),
              const SizedBox(height: 10),
              TextButton(
                onPressed: _loadStamps,
                child: const Text('Retry'),
              ),
            ],
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('No recent stamp activity found'),
          );
        }

        final activations = snapshot.data!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Table Header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      'CUSTOMER',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: widget.lightTextColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'STAMPS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: widget.lightTextColor,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'TIME',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: widget.lightTextColor,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 24, thickness: 1),
            // Table Rows
            ...activations.map((activation) => _buildTableRow(activation)).toList(),
          ],
        );
      },
    );
  }

  Widget _buildTableRow(StampActivation activation) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          // Customer Column
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: widget.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_outline,
                    color: widget.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _truncateName(activation.username),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: widget.darkTextColor,
                  ),
                ),
              ],
            ),
          ),
          // Stamps Column
          Expanded(
            flex: 2,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: widget.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${activation.activeStamps}/${activation.totalStamps}',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: widget.primaryColor,
                  ),
                ),
              ),
            ),
          ),
          // Time Column
          Expanded(
            flex: 2,
            child: Text(
              activation.timeAgo,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: widget.lightTextColor,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  String _truncateName(String name) {
    return name.length > 15 ? '${name.substring(0, 15)}...' : name;
  }
}
