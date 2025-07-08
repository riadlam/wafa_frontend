import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:loyaltyapp/widgets/search_app_bar.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onSearchIconTap;
  final String title;
  const CustomAppBar({super.key, this.onSearchIconTap, this.title = 'Explore'});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: SearchAppBar(
        showBackButton: false,
        title: title,
        enableSearch: true,
        onSearchIconTap: () => context.go('/search'),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
