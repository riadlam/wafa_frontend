import 'package:flutter/material.dart';

/// A widget that provides animated transitions between screens with a slide and fade effect.
/// It automatically determines the slide direction based on the navigation flow.
class AnimatedScreenTransition extends StatelessWidget {
  /// The current index of the screen being displayed
  final int currentIndex;
  
  /// The previous index of the screen (used to determine animation direction)
  final int previousIndex;
  
  /// The child widget to be animated
  final Widget child;
  
  /// The duration of the animation
  final Duration duration;
  
  /// The curve for the slide animation
  final Curve slideCurve;
  
  /// The curve for the fade animation
  final Curve fadeCurve;
  
  const AnimatedScreenTransition({
    Key? key,
    required this.currentIndex,
    required this.previousIndex,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.slideCurve = Curves.easeOutQuart,
    this.fadeCurve = Curves.easeInOutCubic,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      transitionBuilder: (Widget child, Animation<double> animation) {
        // Get the slide direction based on navigation
        final direction = _getSlideDirection(previousIndex, currentIndex);
        
        // Calculate begin offset based on direction
        final beginOffset = _getBeginOffset(direction);
        
        return SlideTransition(
          position: Tween<Offset>(
            begin: beginOffset,
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: slideCurve,
          )),
          child: FadeTransition(
            opacity: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: fadeCurve,
            )),
            child: child,
          ),
        );
      },
      child: KeyedSubtree(
        key: ValueKey<int>(currentIndex),
        child: child,
      ),
    );
  }

  // Helper method to get the slide direction based on navigation
  AxisDirection _getSlideDirection(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      return AxisDirection.left;
    } else if (newIndex < oldIndex) {
      return AxisDirection.right;
    }
    return AxisDirection.down;
  }

  // Helper method to get the begin offset based on direction
  Offset _getBeginOffset(AxisDirection direction) {
    switch (direction) {
      case AxisDirection.right:
        return const Offset(-0.2, 0.0);
      case AxisDirection.left:
        return const Offset(0.2, 0.0);
      default:
        return const Offset(0.0, 0.2);
    }
  }
}
