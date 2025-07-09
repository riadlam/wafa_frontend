import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:loyaltyapp/constants/app_colors.dart';
import 'package:loyaltyapp/constants/routes.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'subscription_pricing_screen.dart';

class SubscriptionSuccessScreen extends StatelessWidget {
  final SubscriptionPlan plan;
  final bool isFreeTrial;
  final DateTime? trialEndsAt;

  const SubscriptionSuccessScreen({
    Key? key,
    required this.plan,
    required this.isFreeTrial,
    this.trialEndsAt,
  }) : super(key: key);

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _handleContinue(BuildContext context) {
    if (context.mounted) {
      // Navigate to shop owner setup screen
      context.go(Routes.shopOwnerSetup);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final size = MediaQuery.of(context).size; // Kept for future responsive layouts

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Successful'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success icon with animation
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Lottie.asset(
                  'assets/animations/categories/check.json',
                  repeat: false, // Play only once
                  frameRate: FrameRate(60), // Smoother animation
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                isFreeTrial
                    ? 'Free Trial Activated!'
                    : 'Subscription Successful!',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 32),

              // Plan details card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      plan.name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isFreeTrial
                          ? '30-Day Free Trial'
                          : '\$${plan.price.toStringAsFixed(2)} / ${plan.billing.replaceAll('billed ', '')}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Subtitle
              Text(
                isFreeTrial
                    ? trialEndsAt != null
                        ? 'Your 30-day free trial has been activated! It will expire on ${_formatDate(trialEndsAt)}. Start building your customer base today.'
                        : 'Your 30-day free trial has been activated! Start building your customer base today.'
                    : 'Your ${plan.name} subscription is now active! Thank you for choosing us.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Continue button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _handleContinue(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Continue to Shop Setup',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
