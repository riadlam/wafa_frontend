import 'package:flutter/material.dart';
import 'package:loyaltyapp/screens/home/banner.dart';
import 'package:loyaltyapp/screens/home/categories_grid.dart';
import 'package:loyaltyapp/screens/profile/profile_page.dart';
import 'package:loyaltyapp/screens/search/search_screen.dart';
import 'package:loyaltyapp/screens/subscribedloyaltycards/sbscribed_loyalty_cards.dart';
import 'package:go_router/go_router.dart';
import 'package:loyaltyapp/constants/custom_app_bar.dart';
import 'package:loyaltyapp/widgets/animated_screen_transition.dart';
import 'package:loyaltyapp/widgets/custom_bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  final int selectedTab;
  const HomeScreen({super.key, this.selectedTab = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late int _selectedIndex;
  int _previousIndex = 0; // Track previous index for animation direction
  late AnimationController _animationController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedTab;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Animation setup for future use
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  final List<Widget> _widgetOptions = <Widget>[
    const HomeTab(),
    const SearchScreen(),
    const SbscribedLoyaltyCards(),
    const ProfilePage(),
  ]
      .map((widget) => HeroControllerScope(
            controller: HeroController(),
            child: widget,
          ))
      .toList();

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _previousIndex = _selectedIndex;
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,

      body: AnimatedScreenTransition(
        currentIndex: _selectedIndex,
        previousIndex: _previousIndex,
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: (GoRouterState.of(context).uri.toString() == '/search')
            ? 1
            : (GoRouterState.of(context).uri.toString() == '/cards')
                ? 2
                : (GoRouterState.of(context).uri.toString() == '/profile')
                    ? 3
                    : (GoRouterState.of(context).uri.toString() == '/' ||
                            GoRouterState.of(context).uri.toString() == '/home')
                        ? 0
                        : (_selectedIndex == 2 ? 2 :
                            _selectedIndex == 1 ? 1 :
                            _selectedIndex == 3 ? 3 : 0),
        onTabSelected: (int index) {
          // If search icon tapped, navigate to SearchScreen route
          if (index == 1) {
            // Use GoRouter to navigate to search
            if (mounted) {
              GoRouter.of(context).go('/search');
            }
            return;
          }
          // Map other nav bar indices to _widgetOptions indices
          int mappedIndex = index;
          if (index >= 1) mappedIndex++;
          if (_selectedIndex != mappedIndex) {
            setState(() {
              _previousIndex = _selectedIndex;
              _selectedIndex = mappedIndex;
            });
          }
        },
        onQrTap: () {
          GoRouter.of(context).go('/profile');
        },
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Explore'),
      body: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Animated Banner
            HomeBanner(),
            // Categories Grid
            CategoriesGrid(),
            // Add some bottom padding
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
