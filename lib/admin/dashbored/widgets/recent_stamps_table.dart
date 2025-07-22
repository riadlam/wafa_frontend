import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loyaltyapp/models/stamp_activation_model.dart';
import 'package:loyaltyapp/services/stamp_service.dart';
import 'package:loyaltyapp/scalaton_loader/recent_stamps_skeleton.dart';
import 'package:easy_localization/easy_localization.dart';

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
          return Center(
            child: Text('recent_stamps.no_activity'.tr()),
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
                      'recent_stamps.customer'.tr(),
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
                      'recent_stamps.stamps'.tr(),
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
                      'recent_stamps.time'.tr(),
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
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Customer Column
              Expanded(
                flex: 4,
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: widget.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person_outline,
                        color: widget.primaryColor,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        _truncateName(activation.username),
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: widget.darkTextColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Stamps Column
              Container(
                width: 80,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${activation.activeStamps}/${activation.totalStamps}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: widget.primaryColor,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              // Time Column
              Container(
                width: 70,
                child: Text(
                  activation.timeAgo,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: widget.lightTextColor,
                  ),
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _truncateName(String name) {
    return name.length > 15 ? '${name.substring(0, 15)}...' : name;
  }
}
