import 'package:flutter/material.dart';

class CustomPageRoute extends PageRouteBuilder {
  final Widget child;
  final AxisDirection direction;
  final Duration duration;

  CustomPageRoute({
    required this.child,
    this.direction = AxisDirection.right,
    this.duration = const Duration(milliseconds: 300),
  }) : super(
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          pageBuilder: (context, animation, secondaryAnimation) => child,
        );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Calculate begin offset based on direction
    Offset getBeginOffset() {
      switch (direction) {
        case AxisDirection.right:
          return const Offset(-1.0, 0.0);
        case AxisDirection.left:
          return const Offset(1.0, 0.0);
        case AxisDirection.up:
          return const Offset(0.0, 1.0);
        case AxisDirection.down:
          return const Offset(0.0, -1.0);
      }
    }

    return SlideTransition(
      position: Tween<Offset>(
        begin: getBeginOffset(),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutQuart,
      )),
      child: FadeTransition(
        opacity: Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutCubic,
        )),
        child: child,
      ),
    );
  }
}
