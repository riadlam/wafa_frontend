import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter/services.dart';

class TiltCard extends StatefulWidget {
  final Widget child;
  final double maxTilt;
  final double maxRotation;
  final double perspective;
  final Duration duration;

  const TiltCard({
    Key? key,
    required this.child,
    this.maxTilt = 0.01,
    this.maxRotation = 0.1,
    this.perspective = 0.0006,
    this.duration = const Duration(milliseconds: 100),
  }) : super(key: key);

  @override
  _TiltCardState createState() => _TiltCardState();
}

class _TiltCardState extends State<TiltCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _tiltAnimation;
  
  double _xTilt = 0.0;
  double _yTilt = 0.0;
  double _xRotation = 0.0;
  double _yRotation = 0.0;
  
  StreamSubscription<dynamic>? _streamSubscription;
  bool _sensorsAvailable = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    
    _tiltAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuad,
    ));
    
    _controller.forward();
    _initSensors();
  }

  Future<void> _initSensors() async {
    try {
      // Try to listen to accelerometer events directly
      _streamSubscription = accelerometerEvents.listen((AccelerometerEvent event) {
        if (!mounted) return;
        
        final double x = (event.x * widget.maxTilt).clamp(-widget.maxTilt, widget.maxTilt);
        final double y = (event.y * widget.maxTilt).clamp(-widget.maxTilt, widget.maxTilt);
        
        setState(() {
          _sensorsAvailable = true;
          _xTilt = x;
          _yTilt = y;
          _xRotation = y * widget.maxRotation;
          _yRotation = x * widget.maxRotation;
        });
      });
      
      // Set a timeout to handle cases where sensors might not be available
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted && !_sensorsAvailable) {
          setState(() {
            _sensorsAvailable = false;
          });
        }
      });
    } on PlatformException catch (e) {
      debugPrint('Failed to initialize sensors: $e');
      if (mounted) {
        setState(() {
          _sensorsAvailable = false;
        });
      }
    }
  }
  
  @override
  void dispose() {
    _streamSubscription?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_sensorsAvailable) {
      // Fallback to a simple hover animation if sensors are not available
      return TweenAnimationBuilder<Offset>(
        tween: Tween(
          begin: const Offset(0, 0),
          end: const Offset(0, -2),
        ),
        duration: const Duration(seconds: 2),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          return Transform.translate(
            offset: value,
            child: child,
          );
        },
        child: widget.child,
      );
    }

    // Use sensor-based tilt effect if sensors are available
    return AnimatedBuilder(
      animation: _tiltAnimation,
      builder: (context, child) {
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, widget.perspective)
            ..rotateX(_xRotation)
            ..rotateY(_yRotation),
          alignment: FractionalOffset.center,
          child: Transform(
            transform: Matrix4.identity()
              ..translate(_xTilt * 20, _yTilt * 20),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
