import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:loyaltyapp/constants/app_colors.dart';
import 'package:loyaltyapp/widgets/curved_notched_bar_painter.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onQrTap;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.onQrTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60, // Just enough for icons + 5px above bar
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // Curved notched background bar
          CustomPaint(
            painter:
                CurvedNotchedBarPainter(backgroundColor: Colors.transparent),
            child: Container(
              height: 58,
              padding: const EdgeInsets.only(
                  left: 24, right: 24, top: 5, bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _NavBarIcon(
                    icon: LucideIcons.home,
                    selectedIcon: LucideIcons.home,
                    selected: selectedIndex == 0,
                    onTap: () {
                      GoRouter.of(context).go('/home');
                    },
                  ),
                  _NavBarIcon(
                    icon: LucideIcons.search,
                    selectedIcon: LucideIcons.search,
                    selected: selectedIndex == 1,
                    onTap: () => onTabSelected(1),
                  ),
                  const SizedBox(width: 56), // Space for QR button
                  _NavBarIcon(
                    icon: LucideIcons.creditCard,
                    selectedIcon: LucideIcons.creditCard,
                    selected: selectedIndex == 2,
                    onTap: () {
                      GoRouter.of(context).go('/cards');
                    },
                  ),
                  _NavBarIcon(
                    icon: LucideIcons.user,
                    selectedIcon: LucideIcons.user,
                    selected: selectedIndex == 3,
                    onTap: () {
                      GoRouter.of(context).go('/profile');
                    },
                  ),
                ],
              ),
            ),
          ),
          // More pronounced notch (curved negative space) under QR Code Button
          Positioned(
            bottom: 0, // Lower, to create a bigger gap
            child: Container(
              width: 90,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
          // Floating QR Code Button
          Positioned(
            bottom: 20, // Move the button up to float above the notch
            child: GestureDetector(
              onTap: onQrTap,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    LucideIcons.qrCode,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavBarIcon extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  const _NavBarIcon({
    required this.icon,
    required this.selectedIcon,
    required this.selected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Icon(
          selected ? selectedIcon : icon,
          color: color ?? (selected ? AppColors.primary : Colors.black),
          size: 30,
        ),
      ),
    );
  }
}
