import 'package:flutter/material.dart';
import 'package:loyaltyapp/constants/colors.dart';
import 'package:loyaltyapp/services/subscription_service.dart';
import 'subscription_success_screen.dart';
import 'dart:math';

class SubscriptionPricingScreen extends StatefulWidget {
  const SubscriptionPricingScreen({Key? key}) : super(key: key);

  @override
  State<SubscriptionPricingScreen> createState() => _SubscriptionPricingScreenState();
}

class _SubscriptionPricingScreenState extends State<SubscriptionPricingScreen> {
  int _selectedPlanIndex = 1; // Default to 3 months
  bool _isYearlyBilling = false;

  final List<SubscriptionPlan> _plans = [
    SubscriptionPlan(
      name: '1 Month',
      price: 14.99,
      billing: 'billed monthly',
      isPopular: false,
      features: [
        'All Basic Features',
        'Up to 100 Customers',
        'Basic Analytics',
      ],
    ),
    SubscriptionPlan(
      name: '3 Months',
      price: 12.99,
      billing: 'billed quarterly',
      isPopular: true,
      features: [
        'Everything in 1 Month',
        'Up to 500 Customers',
        'Advanced Analytics',
        'Priority Support',
      ],
    ),
    SubscriptionPlan(
      name: '12 Months',
      price: 9.99,
      billing: 'billed annually',
      isPopular: false,
      features: [
        'Everything in 3 Months',
        'Unlimited Customers',
        'Advanced Analytics',
        'Priority Support',
      ],
      savings: 'Save 33%',
    ),
  ];

  final ScrollController _scrollController = ScrollController();
  final double _scrollAmount = 300.0; // Adjust this value based on your card width

  void _scrollLeft() {
    _scrollController.animateTo(
      max(0, _scrollController.offset - _scrollAmount),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollRight() {
    _scrollController.animateTo(
      min(_scrollController.position.maxScrollExtent, _scrollController.offset + _scrollAmount),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildNavigationArrow(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.white.withOpacity(0.8),
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withOpacity(0.1),
          ),
          child: Icon(
            icon,
            size: 20,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildBillingToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: _BillingOption(
              label: 'Monthly',
              isActive: !_isYearlyBilling,
              onTap: () => setState(() => _isYearlyBilling = false),
            ),
          ),
          Expanded(
            child: _BillingOption(
              label: 'Yearly',
              isActive: _isYearlyBilling,
              onTap: () => setState(() => _isYearlyBilling = true),
            ),
          ),
        ],
      ),
    );
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
                      icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Choose Your Plan',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Header
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Start Growing Your Business',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Choose the plan that fits your business needs',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Billing toggle
                _buildBillingToggle(),
                if (_isYearlyBilling)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '2 Months Free with Yearly Billing',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),

                // Plans ListView with navigation arrows
                Column(
                  children: [
                    // Navigation arrows - only show if there's content to scroll
                    if (_plans.length > 1)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Left arrow (only show if not at the start)
                            if (_scrollController.hasClients && _scrollController.offset > 0)
                              _buildNavigationArrow(Icons.arrow_back_ios, _scrollLeft)
                            else
                              const SizedBox(width: 40), // Placeholder for layout
                            
                            // Right arrow (only show if not at the end)
                            if (_scrollController.hasClients && 
                                _scrollController.offset < _scrollController.position.maxScrollExtent)
                              _buildNavigationArrow(Icons.arrow_forward_ios, _scrollRight)
                            else
                              const SizedBox(width: 40), // Placeholder for layout
                          ],
                        ),
                      ),
                    
                    // Plans ListView with constrained height
                    Container(
                      height: MediaQuery.of(context).size.height * 0.6 ,// 70% of screen height
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListView.builder(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        itemCount: _plans.length,
                        itemExtent: 320, // Fixed width for each card
                        itemBuilder: (context, index) {
                          final plan = _plans[index];
                          final isSelected = _selectedPlanIndex == index;
                          return GestureDetector(
                            onTap: () {
                              setState(() => _selectedPlanIndex = index);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: isSelected ? 0 : 16,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                  ? AppColors.surface
                                  : AppColors.background,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                    ? AppColors.primary
                                    : Colors.grey.shade300,
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primary.withOpacity(0.1),
                                        blurRadius: 15,
                                        offset: const Offset(0, 5),
                                      ),
                                    ]
                                  : null,
                              ),
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (plan.isPopular)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'MOST POPULAR',
                                        style: theme.textTheme.labelSmall?.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 16),
                                  Text(
                                    plan.name,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  RichText(
                                    text: TextSpan(
                                      text: '\$${plan.price.toStringAsFixed(2)}',
                                      style: theme.textTheme.headlineMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: ' /mo',
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            color: AppColors.textSecondary,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (plan.savings != null) ...{
                                    const SizedBox(height: 8),
                                    Text(
                                      plan.savings!,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: AppColors.success,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  },
                                  const SizedBox(height: 16),
                                  Text(
                                    plan.billing,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  ...plan.features.map((feature) => Padding(
                                        padding: const EdgeInsets.only(bottom: 12.0),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.check_circle,
                                              color: AppColors.primary,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              feature,
                                              style: theme.textTheme.bodyMedium?.copyWith(
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )),
                                  const SizedBox(height: 16),
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      minHeight: 56,
                                      minWidth: 200, // Fixed minimum width
                                    ),
                                    child: FilledButton(
                                      onPressed: () {
                                        // Handle subscription
                                        _handleSubscribe(plan);
                                      },
                                      style: FilledButton.styleFrom(
                                        minimumSize: const Size(200, 56), // Fixed size
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        backgroundColor: isSelected
                                          ? AppColors.primary
                                          : Colors.grey.shade100,
                                        foregroundColor: isSelected
                                            ? Colors.white
                                            : AppColors.textPrimary,
                                      ),
                                      child: Text(
                                        'Get Started',
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: isSelected
                                              ? Colors.white
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    
                  ],
                ),
                const SizedBox(height: 16),

                // Free trial button
                OutlinedButton(
                  onPressed: () {
                    _handleFreeTrial();
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                  child: Text(
                    'Start 30-Day Free Trial',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

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
                      'Secure payment. Cancel anytime.',
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

  void _handleSubscribe(SubscriptionPlan plan) {
    // Handle subscription logic here
    // For now, navigate to success screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubscriptionSuccessScreen(
          plan: plan,
          isFreeTrial: false,
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
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
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
              builder: (context) => SubscriptionSuccessScreen(
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
                trialEndsAt: userData['trial_ends_at'] != null 
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
              content: Text(response['error'] ?? 'Failed to activate free trial'),
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

class _BillingOption extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _BillingOption({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: isActive ? Colors.white : AppColors.textSecondary,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
        ),
      ),
    );
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
