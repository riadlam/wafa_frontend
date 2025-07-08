import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class NotificationSoundPlayer {
  static const MethodChannel _channel = 
      const MethodChannel('notification_sound');
  static bool _isInitialized = false;

  static Future<void> _initialize() async {
    if (!_isInitialized && Platform.isAndroid) {
      try {
        debugPrint('Initializing notification sound...');
        await _channel.invokeMethod('initialize');
        _isInitialized = true;
        debugPrint('Notification sound initialized successfully');
      } catch (e, stackTrace) {
        debugPrint('Error initializing notification sound: $e');
        debugPrint('Stack trace: $stackTrace');
        rethrow;
      }
    }
  }

  static Future<void> play() async {
    if (!Platform.isAndroid) {
      debugPrint('Notification sounds are only supported on Android');
      return;
    }

    try {
      debugPrint('Playing notification sound...');
      await _initialize();
      await _channel.invokeMethod('playNotificationSound');
      debugPrint('Notification sound played successfully');
    } catch (e, stackTrace) {
      debugPrint('Error playing notification sound: $e');
      debugPrint('Stack trace: $stackTrace');
      // Don't rethrow to prevent app crashes
    }
  }

  static Future<void> dispose() async {
    _isInitialized = false;
    debugPrint('Notification sound player disposed');
  }
}

class MessagePopupScreen extends StatefulWidget {
  final String message;
  final bool isError;
  final VoidCallback? onClose;
  final Duration displayDuration;
  final String? customAnimation;
  final Color? backgroundColor;
  final Color? textColor;
  final bool autoDismiss;

  const MessagePopupScreen({
    Key? key,
    required this.message,
    this.isError = false,
    this.onClose,
    this.displayDuration = const Duration(seconds: 0), // 0 means no auto-dismiss
    this.customAnimation,
    this.backgroundColor,
    this.textColor,
    this.autoDismiss = false,
  }) : super(key: key);

  @override
  State<MessagePopupScreen> createState() => _MessagePopupScreenState();

  static Future<void> show(
    BuildContext context, {
    required String message,
    bool isError = false,
    Duration? displayDuration,
    Widget? customIcon,
    Color? backgroundColor,
    Color? textColor,
    VoidCallback? onClose,
    bool autoDismiss = false,
  }) async {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true, // Allow dismissing by tapping outside
      barrierLabel: 'Dismiss dialog',
      barrierColor: Colors.black87.withOpacity(0.7), // Darker semi-transparent background
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (_, __, ___) => _MessagePopupContent(
        message: message,
        isError: isError,
        displayDuration: displayDuration ?? const Duration(seconds: 0),
        customIcon: customIcon,
        backgroundColor: backgroundColor,
        textColor: textColor,
        onClose: onClose,
        autoDismiss: autoDismiss,
      ),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutQuint,
          ),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutBack,
              ),
            ),
            child: child,
          ),
        );
      },
    );
  }
}

class _MessagePopupScreenState extends State<MessagePopupScreen> {
  @override
  Widget build(BuildContext context) {
    // This widget is just a placeholder, the actual content is shown via showGeneralDialog
    return const SizedBox.shrink();
  }
}

class _MessagePopupContent extends StatefulWidget {
  final String message;
  final bool isError;
  final Duration displayDuration;
  final Widget? customIcon;
  final Color? backgroundColor;
  final Color? textColor;
  final VoidCallback? onClose;
  final bool autoDismiss;

  const _MessagePopupContent({
    Key? key,
    required this.message,
    required this.isError,
    required this.displayDuration,
    this.customIcon,
    this.backgroundColor,
    this.textColor,
    this.onClose,
    this.autoDismiss = false,
  }) : super(key: key);

  @override
  _MessagePopupContentState createState() => _MessagePopupContentState();
}

class _MessagePopupContentState extends State<_MessagePopupContent> 
    with SingleTickerProviderStateMixin {
  bool _isSoundPlayed = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  Timer? _dismissTimer;
  bool _isClosing = false;

  @override
  void initState() {
    super.initState();
    _playNotificationSound();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // Start the animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.forward();
      }
    });
    
    // Only start auto-dismiss timer if autoDismiss is true and duration is > 0
    if (widget.autoDismiss && widget.displayDuration.inMilliseconds > 0) {
      _startDismissTimer();
    }
  }

  void _startDismissTimer() {
    _dismissTimer = Timer(widget.displayDuration, () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  Future<void> _dismiss() async {
    if (_isClosing) return;
    _isClosing = true;
    
    await _controller.reverse();
    if (mounted) {
      Navigator.of(context).pop();
      widget.onClose?.call();
    }
  }

  void _playNotificationSound() {
    if (!_isSoundPlayed) {
      _isSoundPlayed = true;
      // Play the notification sound
      NotificationSoundPlayer.play();
    }
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    if (!_isClosing) {
      widget.onClose?.call();
    }
    NotificationSoundPlayer.dispose();
    super.dispose();
  }

  @override
  void deactivate() {
    // Clean up resources when the widget is removed from the tree
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    // Theme and colors
    
    // Colors
    final backgroundColor = widget.backgroundColor ?? 
        (widget.isError 
            ? Colors.red.shade50
            : colorScheme.surface);
            
    final textColor = widget.textColor ?? 
        (widget.isError 
            ? Colors.red.shade900 
            : colorScheme.onSurface);
    
    final primaryColor = widget.isError 
        ? colorScheme.error 
        : colorScheme.primary;

    // Icon
    final icon = widget.customIcon ?? Icon(
      widget.isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
      size: 64,
      color: primaryColor,
    );

    return WillPopScope(
      onWillPop: () async {
        await _dismiss();
        return false;
      },
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Close button (top right)
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withOpacity(0.05),
                            ),
                            child: const Icon(Icons.close, size: 20),
                          ),
                          onPressed: _dismiss,
                        ),
                      ),
                      
                      // Animated Icon
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                        child: AnimatedBuilder(
                          animation: _controller,
                          builder: (context, _) {
                            return Transform.scale(
                              scale: _scaleAnimation.value,
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Opacity(
                                    opacity: _fadeAnimation.value,
                                    child: icon,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      
                      // Message
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                        child: Text(
                          widget.message,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                      ),
                      
                      // Dismiss button
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: ElevatedButton(
                          onPressed: _dismiss,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 0,
                            shadowColor: primaryColor.withOpacity(0.3),
                          ),
                          child: const Text(
                            'Got it',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
