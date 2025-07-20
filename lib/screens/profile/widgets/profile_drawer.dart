import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loyaltyapp/constants/app_colors.dart';
import 'package:loyaltyapp/constants/routes.dart';

import 'package:loyaltyapp/services/logout_service.dart';
import 'package:loyaltyapp/screens/profile/widgets/drawer_item.dart';


class ProfileDrawer extends StatelessWidget {
  const ProfileDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    return Drawer(
      width: screenSize.width * 0.8,
      child: SafeArea(
        child: Container(
          color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // App Logo/Title
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Center(
                child: Text(
                  'Menu',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 20 : 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            
            // Drawer Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                children: [
                  DrawerItem(
                    icon: Icons.person_outline,
                    title: 'Edit Profile',
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to edit profile
                    },
                  ),
                  const SizedBox(height: 4),
                  DrawerItem(
                    icon: Icons.history,
                    title: 'History',
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to history
                    },
                  ),
                  const SizedBox(height: 4),
                  DrawerItem(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to settings
                    },
                  ),
                  const SizedBox(height: 4),
                  DrawerItem(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to help & support
                    },
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 1, thickness: 0.5, indent: 16, endIndent: 16),
                  const SizedBox(height: 8),
                  DrawerItem(
                    icon: Icons.logout,
                    title: 'Logout',
                    textColor: Colors.red,
                    iconColor: Colors.red,
                    onTap: () => _showLogoutConfirmation(context),
                  ),
                ],
              ),
            ),
            
            // App Version
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Version 1.0.0',
                textAlign: TextAlign.center,
                style: GoogleFonts.roboto(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }
  
  Future<void> _showLogoutConfirmation(BuildContext context) async {
    print('🔄 [ProfileDrawer] Showing logout confirmation dialog');
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Logout',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure you want to log out?',
            style: GoogleFonts.roboto(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                print('❌ [ProfileDrawer] Logout cancelled by user');
                Navigator.of(context).pop(false);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[700], 
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              ),
              child: Text(
                'CANCEL',
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              ),
              child: Text(
                'LOGOUT',
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      if (context.mounted) {
        Navigator.pop(context); // Close the drawer
        
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          },
        );
        
        final navigator = Navigator.of(context, rootNavigator: true);
        
        try {
          await LogoutService.logout(context);
          
          if (context.mounted) {
            navigator.pop(); // Close loading dialog
            GoRouter.of(context).go(Routes.login);
          }
        } catch (e) {
          if (context.mounted) {
            navigator.pop(); // Close loading dialog
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error during logout: ${e.toString()}'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
            
            GoRouter.of(context).go(Routes.login);
          }
        }
      }
    }
  }
}


