import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildShimmerContainer(width: 200, height: 24),
            const SizedBox(height: 4),
            _buildShimmerContainer(width: 150, height: 16),
          ],
        ),
        actions: [
          _buildShimmerContainer(width: 40, height: 40, isCircle: true),
          const SizedBox(width: 16),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF5003), Color(0xCCFF5003)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        toolbarHeight: 100,
      ),
      body: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 16, bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Loyalty Card Section
              _buildCardSkeleton(),
              const SizedBox(height: 24),
              
              // Stats Grid
              _buildStatsGridSkeleton(),
              const SizedBox(height: 28),
              
              // Recent Stamp Activations Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: _buildShimmerContainer(width: 200, height: 24),
              ),
              const SizedBox(height: 16),
              
              // Recent Activations Table
              _buildRecentActivationsSkeleton(),
              const SizedBox(height: 28),
              
              // Bottom Banner
              _buildBottomBannerSkeleton(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardSkeleton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildShimmerContainer(width: 150, height: 20),
          const SizedBox(height: 16),
          _buildShimmerContainer(width: double.infinity, height: 100),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: _buildShimmerContainer(width: 100, height: 36, radius: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGridSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildStatItemSkeleton()),
              const SizedBox(width: 16),
              Expanded(child: _buildStatItemSkeleton()),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildStatItemSkeleton()),
              const SizedBox(width: 16),
              Expanded(child: _buildStatItemSkeleton()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItemSkeleton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildShimmerContainer(width: 40, height: 40, isCircle: true),
          const SizedBox(height: 12),
          _buildShimmerContainer(width: 80, height: 16),
          const SizedBox(height: 4),
          _buildShimmerContainer(width: 60, height: 20),
        ],
      ),
    );
  }

  Widget _buildRecentActivationsSkeleton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: List.generate(5, (index) => _buildTableRowSkeleton()),
      ),
    );
  }

  Widget _buildTableRowSkeleton() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildShimmerContainer(width: 32, height: 32, isCircle: true),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShimmerContainer(width: 120, height: 14),
                const SizedBox(height: 4),
                _buildShimmerContainer(width: 80, height: 12),
              ],
            ),
          ),
          _buildShimmerContainer(width: 60, height: 14),
        ],
      ),
    );
  }

  Widget _buildBottomBannerSkeleton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF6C63FF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShimmerContainer(width: 160, height: 20),
                const SizedBox(height: 8),
                _buildShimmerContainer(width: 200, height: 16),
                const SizedBox(height: 16),
                _buildShimmerContainer(width: 120, height: 40, radius: 20),
              ],
            ),
          ),
          const SizedBox(width: 20),
          _buildShimmerContainer(width: 80, height: 80, isCircle: true),
        ],
      ),
    );
  }

  Widget _buildShimmerContainer({
    required double width,
    required double height,
    double radius = 4.0,
    bool isCircle = false,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: isCircle
            ? null
            : BorderRadius.circular(radius),
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
      ),
    );
  }
}
