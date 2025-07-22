import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loyaltyapp/constants/app_colors.dart';
import 'package:loyaltyapp/constants/routes.dart';
import 'package:loyaltyapp/admin/dashbored/widgets/language_selector_sheet.dart';
import 'package:loyaltyapp/services/logout_service.dart';
import 'package:loyaltyapp/services/account_service.dart';
import 'package:loyaltyapp/services/auth_service.dart';
import 'package:loyaltyapp/screens/profile/widgets/drawer_item.dart';
import 'package:loyaltyapp/screens/profile/edit_profile_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class ProfileDrawer extends StatefulWidget {
  const ProfileDrawer({super.key});

  @override
  State<ProfileDrawer> createState() => _ProfileDrawerState();
}

class _ProfileDrawerState extends State<ProfileDrawer> {
  void _onLanguageChanged() {
    if (mounted) {
      setState(() {
        // This will force a rebuild with the new locale
      });
    }
  }

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
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Center(
                  child: Text(
                    'drawer.menu'.tr(),
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
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 8,
                  ),
                  children: [
                    DrawerItem(
                      icon: Icons.person_outline,
                      title: 'drawer.edit_profile'.tr(),
                      onTap: () async {
                        final authService = AuthService();
                        final currentName = await authService.getUserName() ?? '';
                        
                        if (context.mounted) {
                          Navigator.pop(context);
                          final result = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProfileScreen(
                                currentName: currentName,
                              ),
                            ),
                          );
                          
                          if (result == true && context.mounted) {
                            // Trigger a rebuild if needed
                            setState(() {});
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 4),
                    // DrawerItem(
                    //   icon: Icons.history,
                    //   title: 'drawer.history'.tr(),
                    //   onTap: () {
                    //     Navigator.pop(context);
                    //     // Navigate to history
                    //   },
                    // ),
                    // const SizedBox(height: 4),
                    // DrawerItem(
                    //   icon: Icons.settings_outlined,
                    //   title: 'drawer.settings'.tr(),
                    //   onTap: () {
                    //     Navigator.pop(context);
                    //     // Navigate to settings
                    //   },
                    // ),
                    const SizedBox(height: 4),
                    DrawerItem(
                      icon: Icons.help_outline,
                      title: 'drawer.help_support'.tr(),
                      onTap: () {
                        Navigator.pop(context);
                        // Navigate to help & support
                      },
                    ),
                    const SizedBox(height: 8),
                    DrawerItem(
                      icon: Icons.language,
                      title: 'drawer.language'.tr(),
                      onTap: () {
                        Navigator.pop(context);
                        showModalBottomSheet(
                          context: context,
                          builder:
                              (context) => LanguageSelectorSheet(
                                onLanguageChanged: _onLanguageChanged,
                              ),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 4),
                    const Divider(
                      height: 1,
                      thickness: 0.5,
                      indent: 16,
                      endIndent: 16,
                    ),
                    const SizedBox(height: 8),
                    // Delete Account Option
                    Padding(
                      key: const ValueKey('delete_account_button'),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _showDeleteAccountConfirmation(context),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 12.0,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete_forever_outlined,
                                  color: Colors.red,
                                  size: 24,
                                ),
                                const SizedBox(width: 24),
                                Text(
                                  'drawer.delete_account'.tr(),
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Logout Option
                    Padding(
                      key: const ValueKey('logout_button'),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _showLogoutConfirmation(context),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 12.0,
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.logout, color: Colors.red, size: 24),
                                const SizedBox(width: 24),
                                Text(
                                  'drawer.logout'.tr(),
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // App Version
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'drawer.version'.tr(namedArgs: {'version': '1.0.0'}),
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

  Future<void> _showDeleteAccountConfirmation(BuildContext context) async {
    print('🔄 [ProfileDrawer] Showing delete account confirmation dialog');
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'drawer.delete_account_title'.tr(),
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: Text(
            'drawer.delete_account_message'.tr(),
            style: GoogleFonts.roboto(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                print('❌ [ProfileDrawer] Account deletion cancelled by user');
                Navigator.of(context).pop(false);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[700],
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
              ),
              child: Text(
                'drawer.cancel'.tr(),
                style: GoogleFonts.roboto(fontWeight: FontWeight.w500),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
              ),
              child: Text(
                'drawer.confirm_delete'.tr(),
                style: GoogleFonts.roboto(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      try {
        final accountService = AccountService();
        final success = await accountService.deleteAccount();

        if (success) {
          // If account deletion is successful, log the user out
          await LogoutService.logout(context);
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text('drawer.account_deleted_successfully'.tr()),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          throw Exception('Failed to delete account');
        }
      } catch (e) {
        print('❌ [ProfileDrawer] Error deleting account: $e');
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('drawer.account_deletion_failed'.tr()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
            'drawer.logout_title'.tr(),
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: Text(
            'drawer.logout_message'.tr(),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
              ),
              child: Text(
                'drawer.cancel'.tr(),
                style: GoogleFonts.roboto(fontWeight: FontWeight.w500),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
              ),
              child: Text(
                'drawer.confirm_logout'.tr(),
                style: GoogleFonts.roboto(fontWeight: FontWeight.w600),
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
