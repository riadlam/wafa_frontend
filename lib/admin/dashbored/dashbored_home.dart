import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loyaltyapp/constants/app_colors.dart';
import 'package:loyaltyapp/services/stamp_service.dart';
import 'package:loyaltyapp/providers/loyalty_card_provider.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:io';
import 'dashbored_profile.dart';
import 'screens/qr_code_screen.dart';
import 'package:loyaltyapp/scalaton_loader/dashboard_skeleton.dart';
import 'package:loyaltyapp/admin/dashbored/widgets/loyalty_card_display.dart';
import 'package:loyaltyapp/admin/dashbored/widgets/edit_loyalty_card_sheet.dart';
import 'package:loyaltyapp/constants/app_colors.dart' as custom_colors;
import 'package:loyaltyapp/admin/dashbored/widgets/recent_stamps_table.dart';

class DashboardHome extends StatefulWidget {
  const DashboardHome({super.key});

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const _DashboardContent(),
    const QrCodeScreen(),
    const DashboardProfile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        height: 80, // Slightly taller to accommodate the floating button
        padding: const EdgeInsets.only(top: 10), // Add some top padding
        child: Stack(
          alignment: Alignment.topCenter, // Align to top to handle overflow
          clipBehavior: Clip.none, // Allow overflow for the floating button
          children: [
            // Background bar with notch
            Container(
              height: 60,
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Left side items
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _NavBarIcon(
                          icon: LucideIcons.layoutDashboard,
                          selectedIcon: LucideIcons.layoutDashboard,
                          selected: _currentIndex == 0,
                          onTap: () => setState(() => _currentIndex = 0),
                        ),
                      ],
                    ),
                  ),

                  // Invisible spacer for the center button area
                  const SizedBox(
                    width: 70,
                  ), // Matches the width of the floating button
                  // Right side items
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _NavBarIcon(
                          icon: LucideIcons.user,
                          selectedIcon: LucideIcons.user,
                          selected: _currentIndex == 2,
                          onTap: () => setState(() => _currentIndex = 2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Floating QR Code Button (centered)
            Positioned(
              bottom: 30, // Position at the top of the Stack
              child: GestureDetector(
                onTap: () => setState(() => _currentIndex = 1),
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: custom_colors.AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: custom_colors.AppColors.primary.withOpacity(
                          0.25,
                        ),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: const Center(
                    child: Icon(
                      LucideIcons.qrCode,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavBarIcon extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final bool selected;
  final VoidCallback onTap;

  const _NavBarIcon({
    required this.icon,
    required this.selectedIcon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? selectedIcon : icon,
              color:
                  selected ? custom_colors.AppColors.primary : Colors.black54,
              size: 28,
            ),
            if (selected)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: custom_colors.AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DashboardContent extends StatefulWidget {
  const _DashboardContent({super.key});

  @override
  State<_DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<_DashboardContent> {
  // Controllers and state for edit sheet
  late final TextEditingController _shopNameController;
  late final TextEditingController _stampsController;
  late final ValueNotifier<Color> _selectedColor;
  late final ValueNotifier<File?> _logoImage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _shopNameController = TextEditingController();
    _stampsController = TextEditingController();
    _selectedColor = ValueNotifier(const Color(0xFF6C63FF));
    _logoImage = ValueNotifier<File?>(null);

    // Initialize the future
    _planInfoFuture = _stampService.getPlanInfo();

    // Fetch initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch loyalty card data
      final provider = Provider.of<LoyaltyCardProvider>(context, listen: false);
      provider
          .fetchCardData()
          .then((_) {
            if (mounted) {
              _updateControllersFromProvider(provider);
              setState(() {
                _isLoading = false;
              });
            }
          })
          .catchError((error) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          });
    });
  }

  void _updateControllersFromProvider(LoyaltyCardProvider provider) {
    _shopNameController.text = provider.shopName ?? 'My Shop';
    _stampsController.text = provider.totalStamps.toString();
    _selectedColor.value = provider.cardColor;
    if (provider.logoImage != null) {
      _logoImage.value = provider.logoImage;
    }
  }

  // Gradient colors for the app bar
  static const _appBarGradient = LinearGradient(
    colors: [_primaryColor, _test],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Custom card shape
  static final _cardShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
    side: BorderSide(color: Colors.grey.shade200, width: 1),
  );

  // Custom colors
  static const _primaryColor = AppColors.primary;
  static const _primaryDarkColor = AppColors.textPrimary;
  static const _successColor = Color(0xFF10B981);
  static const _warningColor = Color(0xFFF59E0B);
  static const _test = AppColors.primary60;

  final StampService _stampService = StampService();
  late Future<PlanInfo> _planInfoFuture;

  static const _darkTextColor = Color(0xFF1E293B);
  static const _mediumTextColor = Color(0xFF475569);
  static const _lightTextColor = Color(0xFF64748B);
  static const _cardBackground = Colors.white;
  static const _scaffoldBackground = Color(0xFFF8FAFC);
  static const _white = Colors.white;

  @override
  Widget build(BuildContext context) {
    // Show skeleton loading while data is being fetched
    if (_isLoading) {
      return const DashboardSkeleton();
    }

    // Recent redemptions will be displayed from the API data

    return Scaffold(
      backgroundColor: _cardBackground,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Welcome back, Admin! 👋',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5,
                color: Colors.white,
              ),
            ),
            Text(
              'Today’s reward rundown',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white.withOpacity(0.9),
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        centerTitle: false,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: _appBarGradient),
        ),
        foregroundColor: Colors.white,
        toolbarHeight:
            100, // Increased height to accommodate the welcome message
        actions: [
          _buildNotificationButton(),
          const SizedBox(width: 8),
          _buildProfileButton(),
          const SizedBox(width: 16),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color.fromARGB(255, 224, 191, 191).withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            top: 16,
            bottom: 16,
          ), // Remove horizontal padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeHeader(),
              const SizedBox(height: 10),
              _buildLoyaltyCardSection(),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildStatsGrid(),
              ),
              const SizedBox(height: 28),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: _buildSectionHeader(
                  'Recent Stamp Activations',
                  onViewAll: () {},
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildStampActivationsTable(),
              ),
              const SizedBox(height: 28),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildBottomBanner(),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return const SizedBox.shrink(); // Empty widget since we moved welcome to app bar
  }

  Widget _buildLoyaltyCardSection() {
    return Builder(
      builder:
          (context) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'My Loyalty Card',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E293B),
                          letterSpacing: -0.2,
                        ),
                      ),
                      _buildEditButton(),
                    ],
                  ),
                ),
              ),
              const LoyaltyCardDisplay(),
            ],
          ),
    );
  }

  Widget _buildEditButton() {
    return Builder(
      builder:
          (context) => TextButton(
            onPressed: () => _showEditOptions(context),
            style: TextButton.styleFrom(
              foregroundColor: custom_colors.AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: custom_colors.AppColors.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              backgroundColor: custom_colors.AppColors.primary.withOpacity(
                0.05,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.edit, size: 14, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  'Edit Card',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: custom_colors.AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
    );
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _stampsController.dispose();
    _selectedColor.dispose();
    _logoImage.dispose();
    super.dispose();
  }

  void _showEditOptions(BuildContext context) {
    // Get the current provider instance
    final provider = Provider.of<LoyaltyCardProvider>(context, listen: false);

    // Debug prints to check current provider values
    debugPrint('_showEditOptions - Provider values:');
    debugPrint('- shopName: ${provider.shopName}');
    debugPrint('- description: ${provider.description}');
    debugPrint('- totalStamps: ${provider.totalStamps}');
    debugPrint('- cardColor: ${provider.cardColor}');
    debugPrint('- logoUrl: ${provider.logoUrl}');

    // Create new controllers for the bottom sheet to avoid conflicts
    final shopNameController = TextEditingController(
      text: provider.shopName ?? 'My Shop',
    );

    // Ensure description is not null and trim any whitespace
    final descriptionText = provider.description?.trim() ?? '';
    final descriptionController = TextEditingController(text: descriptionText);

    final stampsController = TextEditingController(
      text: provider.totalStamps.toString(),
    );
    final selectedColor = ValueNotifier<Color>(provider.cardColor);
    final logoImage = ValueNotifier<File?>(provider.logoImage);

    // Debug prints to check controller values
    debugPrint('Controller values:');
    debugPrint('- shopNameController: "${shopNameController.text}"');
    debugPrint('- descriptionController: "${descriptionController.text}"');
    debugPrint('- stampsController: "${stampsController.text}"');
    debugPrint('- selectedColor: ${selectedColor.value}');
    debugPrint('- logoImage: ${logoImage.value}');

    // Force a refresh of the provider data before showing the edit sheet
    provider.fetchCardData().then((_) {
      debugPrint('Refreshed provider data before showing edit sheet');
      debugPrint('- New description: ${provider.description}');
    });

    // Show the edit card sheet as a modal bottom sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return EditLoyaltyCardSheet(
          cardId: 1, // You might want to make this dynamic
          shopNameController: shopNameController,
          descriptionController: descriptionController,
          stampsController: stampsController,
          selectedColor: selectedColor,
          logoImage: logoImage,
          onSave: () {
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
          onDelete: () {
            if (context.mounted) {
              Navigator.of(context).pop(); // Close the edit sheet
              _showDeleteConfirmation(context);
            }
          },
          onUpdateSuccess: (
            String logoUrl,
            String color,
            int totalStamps,
          ) async {
            try {
              // Refresh the card data from the provider
              await provider.fetchCardData();

              // Show success message
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Card updated successfully')),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error updating card: ${e.toString()}'),
                  ),
                );
              }
            }
          },
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext dialogContext) {
    showDialog(
      context: dialogContext,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Delete Loyalty Card',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            content: Text(
              'Are you sure you want to delete this loyalty card? This action cannot be undone.',
              style: GoogleFonts.inter(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF64748B),
                ),
                child: Text(
                  'CANCEL',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  // TODO: Implement delete functionality
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Loyalty card deleted',
                        style: GoogleFonts.inter(),
                      ),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: custom_colors.AppColors.primary,
                ),
                child: Text(
                  'DELETE',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildStatsGrid() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: Future.wait<Map<String, dynamic>>([
        _stampService.getRedemptionStats(),
        _stampService.getTotalSubscribers(),
      ]),
      builder: (context, snapshot) {
        // Default values
        String redemptions = '0';
        String subscribers = '0';

        if (snapshot.hasData && snapshot.data != null) {
          final data = snapshot.data!;
          if (data.isNotEmpty) {
            redemptions = (data[0]['total_redemptions'] ?? 0).toString();
            if (data.length > 1) {
              subscribers = (data[1]['total_subscribers'] ?? 0).toString();
            }
          }
        }

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            _buildStatCard(
              'Total Subscribers',
              subscribers,
              Icons.people_alt_outlined,
              const Color(0xFF6366F1),
              infoText:
                  'Total number of customers subscribed to your loyalty program.',
            ),
            FutureBuilder<PlanInfo>(
              future: _planInfoFuture,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final planName =
                      '${snapshot.data!.plan[0].toUpperCase()}${snapshot.data!.plan.substring(1).toLowerCase()}';
                  final expiresIn = 'Expires in ${snapshot.data!.expiresIn}';

                  return _buildStatCard(
                    expiresIn,
                    planName,
                    Icons.verified_user_outlined,
                    _successColor,
                    infoText:
                        'Your current subscription plan details and expiration information. ${snapshot.data!.expiresIn == 'N/A' ? '' : 'To continue enjoying all features, please renew your plan before it expires.'}',
                    showUpgradeButton: true,
                  );
                }
                return _buildStatCard(
                  'Plan',
                  'Loading...',
                  Icons.verified_user_outlined,
                  _successColor,
                );
              },
            ),
            _buildStatCard(
              'Redemptions',
              redemptions,
              Icons.card_giftcard_outlined,
              _warningColor,
              infoText:
                  'Number of rewards redeemed by your customers this month.',
            ),
            // Pending Payment card
            FutureBuilder<dynamic>(
              future: _stampService.getPendingPayment(),
              builder: (context, snapshot) {
                // Show loading state
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildStatCard(
                    'Pending Payment',
                    '...',
                    Icons.payments_outlined,
                    const Color(0xFF8B5CF6),
                  );
                }

                // Show error state
                if (snapshot.hasError) {
                  return _buildStatCard(
                    'Pending Payment',
                    'Error',
                    Icons.error_outline,
                    Colors.red[300]!,
                    infoText: 'Failed to load pending payment',
                  );
                }

                // Show data
                final amount =
                    snapshot.hasData
                        ? snapshot.data!.data.totalAmountDue.toStringAsFixed(0)
                        : '0';
                final pendingAmount = Row(
                  mainAxisSize: MainAxisSize.min,
                  textBaseline: TextBaseline.alphabetic,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  children: [
                    Text(
                      amount,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'DA',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B).withOpacity(0.8),
                      ),
                    ),
                  ],
                );

                return _buildStatCard(
                  'Pending Payment',
                  pendingAmount,
                  Icons.payments_outlined,
                  const Color(0xFF8B5CF6),
                  infoText: 'Total amount pending from unredeemed rewards.',
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    dynamic value, // Can be String or Widget
    IconData icon,
    Color color, {
    String? infoText,
    bool showUpgradeButton = false,
  }) {
    Future<void> _showInfoDialog(BuildContext context) async {
      if (infoText == null) return;

      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  infoText,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                if (showUpgradeButton) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Implement upgrade/renew functionality
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Upgrade/Renew Plan',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            actions:
                showUpgradeButton
                    ? null
                    : <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Got it',
                          style: GoogleFonts.inter(
                            color: _primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
          );
        },
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: color, size: 20),
                    ),
                    if (infoText != null)
                      GestureDetector(
                        onTap: () => _showInfoDialog(context),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          child: const Icon(
                            Icons.info_outline_rounded,
                            color: Color(0xFF94A3B8),
                            size: 18,
                          ),
                        ),
                      ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (value is Widget)
                      value
                    else
                      Text(
                        value,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onViewAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E293B),
          ),
        ),
        if (onViewAll != null)
          TextButton(
            onPressed: onViewAll,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'View All',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _primaryColor,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Quick Actions'),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.add_circle_outline_rounded,
                label: 'Add Reward',
                onTap: () {},
                color: const Color(0xFF6366F1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.bar_chart_rounded,
                label: 'Analytics',
                onTap: () {},
                color: const Color(0xFF10B981),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.mail_outline_rounded,
                label: 'Campaigns',
                onTap: () {},
                color: const Color(0xFFF59E0B),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _lightTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationButton() {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded, size: 24),
          onPressed: () {},
        ),
        Positioned(
          right: 10,
          top: 10,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileButton() {
    return GestureDetector(
      onTap: () {
        // Find the parent DashboardHomeState and update the current index
        _DashboardHomeState? state =
            context.findAncestorStateOfType<_DashboardHomeState>();
        if (state != null && state.mounted) {
          state.setState(() {
            state._currentIndex = 2; // Index of profile in the bottom nav
          });
        }
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.person_outline, color: Colors.white),
      ),
    );
  }

  Widget _buildBottomBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need help with your loyalty program?',
                  style: GoogleFonts.poppins(
                    color: _primaryDarkColor,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Our support team is here to help you get the most out of your loyalty program.',
                  style: GoogleFonts.inter(color: Colors.black, fontSize: 12),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,

                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Contact Support',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Opacity(
            opacity: 0.8,
            child: Icon(Icons.help_outline, color: Colors.black, size: 60),
          ),
        ],
      ),
    );
  }

  Widget _buildStampActivationsTable() {
    return Card(
      elevation: 0,
      shape: _cardShape,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: RecentStampsTable(
          primaryColor: _primaryColor,
          darkTextColor: _darkTextColor,
          lightTextColor: _lightTextColor,
        ),
      ),
    );
  }
}
