import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loyaltyapp/constants/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:loyaltyapp/constants/routes.dart';
import 'package:loyaltyapp/providers/auth_state_provider.dart';
import 'package:loyaltyapp/admin/dashbored/widgets/loyalty_card_display.dart';
import 'package:loyaltyapp/providers/user_provider.dart';

class DashboardProfile extends StatelessWidget {
  const DashboardProfile({super.key});
  
  // Get user initials from name
  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return 'U';
    final nameParts = name.split(' ');
    if (nameParts.length > 1) {
      return '${nameParts[0][0]}${nameParts[1][0]}';
    }
    return name[0];
  }

  // Custom colors matching the dashboard theme
  static const _primaryColor = AppColors.primary;
  static const _scaffoldBackground = Color(0xFFF8F9FF);
  static const _cardBackground = Colors.white;
  static const _lightTextColor = AppColors.primary60;
  static const _darkTextColor = Color(0xFF1E293B);

  @override
  Widget build(BuildContext context) {
    // Initialize user provider if needed
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (!userProvider.isInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        userProvider.initialize();
      });
    }
    return Scaffold(
      backgroundColor: _scaffoldBackground,
      body: CustomScrollView(
        slivers: [
          // App Bar with profile header
          SliverAppBar(
            expandedHeight: 220.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF5003), Color(0xCCFF5003)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Profile Avatar with User Data
                      Consumer<UserProvider>(
                        builder: (context, userProvider, _) {
                          final user = userProvider.user;
                          final displayName = user?.name ?? 'User';
                          final email = user?.email ?? 'No email';
                          // Get the avatar URL from user model
                          final avatarUrl = user?.avatar;
                          
                          return Column(
                            children: [
                              // Profile Avatar
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _primaryColor.withOpacity(0.8).withOpacity(0.1),
                                  border: Border.all(color: Colors.white, width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: avatarUrl != null && avatarUrl.isNotEmpty
                                    ? ClipOval(
                                        child: Image.network(
                                          avatarUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Center(
                                            child: Text(
                                              _getInitials(displayName),
                                              style: const TextStyle(
                                                fontSize: 32,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          loadingBuilder: (context, child, loadingProgress) {
                                            if (loadingProgress == null) return child;
                                            return const Center(
                                              child: CircularProgressIndicator(
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                strokeWidth: 2,
                                              ),
                                            );
                                          },
                                        ),
                                      )
                                    : Center(
                                        child: Text(
                                          _getInitials(displayName),
                                          style: const TextStyle(
                                            fontSize: 32,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                displayName,
                                style: GoogleFonts.poppins(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                email,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        
          
          // Profile content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Account Section
                  _buildSectionTitle('Account'),
                  const SizedBox(height: 16),
                  _buildProfileCard(
                    children: [
                      _buildProfileItem(
                        icon: Icons.person_outline,
                        title: 'Personal Information',
                        subtitle: 'Update your personal details',
                        onTap: () {},
                      ),
                    
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Preferences Section
                  _buildSectionTitle('Preferences'),
                  const SizedBox(height: 16),
                  _buildProfileCard(
                    children: [
                      _buildProfileItem(
                        icon: Icons.language_outlined,
                        title: 'Language',
                        subtitle: 'English (US)',
                        trailing: const Icon(Icons.chevron_right, color: _lightTextColor),
                        onTap: () {},
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Support Section
                  _buildSectionTitle('Support'),
                  const SizedBox(height: 16),
                  _buildProfileCard(
                    children: [
                      _buildProfileItem(
                        icon: Icons.help_outline,
                        title: 'Help Center',
                        subtitle: 'Find answers to common questions',
                        onTap: () {},
                      ),
                      _buildProfileItem(
                        icon: Icons.email_outlined,
                        title: 'Contact Support',
                        subtitle: 'Get in touch with our support team',
                        onTap: () {},
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Show confirmation dialog
                        final shouldLogout = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Logout'),
                              content: const Text('Are you sure you want to log out?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text('CANCEL'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                  child: const Text('LOGOUT'),
                                ),
                              ],
                            );
                          },
                        );

                        // If user confirms logout
                        if (shouldLogout == true) {
                          if (context.mounted) {
                            // Show loading indicator
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                            );
                            
                            try {
                              // Get the auth state provider and sign out
                              final authState = Provider.of<AuthStateProvider>(
                                context,
                                listen: false,
                              );
                              
                              // Sign out through auth state provider
                              await authState.signOut();
                              
                              // Close any open dialogs
                              if (context.mounted) {
                                Navigator.of(context, rootNavigator: true).pop();
                                
                                // Use pushReplacement to prevent going back to protected routes
                                // and ensure we're at the root of the navigation stack
                                final router = GoRouter.of(context);
                                if (router.canPop()) {
                                  router.pop();
                                }
                                router.go(Routes.login);
                              }
                            } catch (e) {
                              if (context.mounted) {
                                // Close loading dialog
                                Navigator.of(context, rootNavigator: true).pop();
                                
                                // Show error message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error during logout: ${e.toString()}'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.red.withOpacity(0.2)),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Logout',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // App Version
                  Center(
                    child: Text(
                      'Waffa v1.0.0',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: _lightTextColor.withOpacity(0.7),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: _darkTextColor,
        letterSpacing: -0.3,
      ),
    );
  }
  
  Widget _buildProfileCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: _cardBackground,
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
        children: children,
      ),
    );
  }
  
  Widget _buildProfileItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    subtitle ??= '';
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _primaryColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: _primaryColor, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: _darkTextColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(
          fontSize: 13,
          color: _lightTextColor,
        ),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: _lightTextColor),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
  
  Widget _buildToggleItem({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _primaryColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: _primaryColor, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: _darkTextColor,
        ),
      ),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: _primaryColor,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}
