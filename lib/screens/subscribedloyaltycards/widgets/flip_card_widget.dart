import 'package:flutter/material.dart';
import 'dart:math' as math;

class FlipCardWidget extends StatefulWidget {
  final Widget front;
  final Widget back;
  final Duration duration;
  final bool flipOnTap;

  const FlipCardWidget({
    super.key,
    required this.front,
    required this.back,
    this.duration = const Duration(milliseconds: 500),
    this.flipOnTap = true,
  });

  @override
  State<FlipCardWidget> createState() => _FlipCardWidgetState();
}

class _FlipCardWidgetState extends State<FlipCardWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isFront = true;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..addListener(() => setState(() {}));
    
    // Add a small delay before starting the initial flip animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _performInitialFlip();
    });
  }
  
  // Perform the initial flip animation
  void _performInitialFlip() {
    if (!mounted) return;
    
    // Start with the card completely flipped (showing back)
    _controller.value = 1.0;
    _isFront = false;
    
    // Then animate to show the front with a nice flip
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() {
        _isFront = true;
        _controller.animateTo(
          0.0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flip() {
    if (_isAnimating) return;
    
    setState(() {
      _isAnimating = true;
      if (_isFront) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
      _isFront = !_isFront;
    });
    
    Future.delayed(widget.duration, () {
      if (mounted) {
        setState(() {
          _isAnimating = false;
        });
      }
    });
  }

  // Handle horizontal drag to flip
  void _handleHorizontalDragUpdate(DragUpdateDetails details) {
    if (_isAnimating) return;
    
    // Calculate the drag distance as a percentage of the card width
    final dragDistance = details.primaryDelta ?? 0;
    final dragPercentage = dragDistance / 100; // Adjust sensitivity
    
    // Update the controller value based on drag
    var newValue = _controller.value + dragPercentage;
    newValue = newValue.clamp(0.0, 1.0); // Keep within valid range
    
    _controller.value = newValue;
  }
  
  // Handle drag end to complete the flip if threshold is passed
  void _handleHorizontalDragEnd(DragEndDetails details) {
    if (_isAnimating) return;
    
    final threshold = 0.5;
    if (_controller.value > threshold) {
      // Complete flip to back
      _controller.animateTo(1.0, duration: widget.duration);
      _isFront = false;
    } else {
      // Return to front
      _controller.animateTo(0.0, duration: widget.duration);
      _isFront = true;
    }
    
    setState(() {
      _isAnimating = true;
    });
    
    Future.delayed(widget.duration, () {
      if (mounted) {
        setState(() {
          _isAnimating = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the size of the front widget to maintain consistent dimensions
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use a fixed size container to prevent layout shifts
        return SizedBox(
          width: constraints.maxWidth,
          // Use a fixed height that matches your card's height
          height: 220, // Adjust this to match your card's height
          child: GestureDetector(
            onTap: widget.flipOnTap ? _flip : null,
            onHorizontalDragUpdate: _handleHorizontalDragUpdate,
            onHorizontalDragEnd: _handleHorizontalDragEnd,
            behavior: HitTestBehavior.opaque,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                // Smooth interpolation for the flip animation
                final angle = _controller.value * math.pi; // 180 degrees in radians
                
                // Determine which widget to show based on the animation progress
                final isFrontVisible = _controller.value < 0.5;
                
                return Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001) // Perspective
                    ..rotateY(angle),
                  alignment: Alignment.center,
                  child: isFrontVisible
                      ? _buildCardFace(widget.front, true)
                      : _buildCardFace(widget.back, false),
                );
              },
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildCardFace(Widget child, bool isFront) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(isFront ? 0 : 3.14159),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: child,
      ),
    );
  }
}
