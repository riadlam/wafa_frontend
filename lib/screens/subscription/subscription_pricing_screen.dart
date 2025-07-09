import 'package:flutter/material.dart';
import 'package:loyaltyapp/constants/app_colors.dart';
import 'package:loyaltyapp/services/subscription_service.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'subscription_success_screen.dart';

class SubscriptionPricingScreen extends StatefulWidget {
  const SubscriptionPricingScreen({Key? key}) : super(key: key);

  @override
  State<SubscriptionPricingScreen> createState() =>
      _SubscriptionPricingScreenState();
}

class _SubscriptionPricingScreenState extends State<SubscriptionPricingScreen> {
  Future<void> _launchWhatsApp() async {
    const phoneNumber = '+1234567890'; // Replace with your WhatsApp number
    const message = 'Hello, I have a question about your subscription plans.';
    final url = 'https://wa.me/$phoneNumber?text=${Uri.encodeFull(message)}';

    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch WhatsApp')),
        );
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button and title
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppColors.primary,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Get Started',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // Header
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Start Your Free Trial',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Try all features free for 30 days. No credit card required.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                // Free trial button
                ElevatedButton(
                  onPressed: _handleFreeTrial,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Start 30-Day Free Trial',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Contact us button
                OutlinedButton(
                  onPressed: _launchWhatsApp,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.network(
                        'https://web.whatsapp.com/favicon.ico',
                        width: 24,
                        height: 24,
                        errorBuilder: (context, error, stackTrace) => 
                            const Icon(Icons.chat, color: Colors.green, size: 24),
                      ),
                      const SizedBox(width: 8),
                      const Flexible(
                        child: Text(
                          'Contact Us on WhatsApp',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Security info
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Secure signup. No credit card required.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleFreeTrial() async {
    // Show loading dialog
    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final subscriptionService = SubscriptionService();
      final response = await subscriptionService.activateFreeTrial();

      if (!context.mounted) return;
      Navigator.of(context).pop(); // Dismiss loading dialog

      if (response['success'] == true) {
        final userData = response['data']['user'];

        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (context) => SubscriptionSuccessScreen(
                    plan: SubscriptionPlan(
                      name: 'Free Trial',
                      price: 0,
                      billing: 'for 30 days',
                      isPopular: false,
                      features: [
                        'All Pro Features',
                        'Up to 500 Customers',
                        'Advanced Analytics',
                        'Priority Support',
                      ],
                    ),
                    isFreeTrial: true,
                    trialEndsAt:
                        userData['trial_ends_at'] != null
                            ? DateTime.parse(userData['trial_ends_at'])
                            : null,
                  ),
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response['error'] ?? 'Failed to activate free trial',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Dismiss loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class SubscriptionPlan {
  final String name;
  final double price;
  final String billing;
  final bool isPopular;
  final List<String> features;
  final String? savings;

  SubscriptionPlan({
    required this.name,
    required this.price,
    required this.billing,
    required this.isPopular,
    required this.features,
    this.savings,
  });
}
