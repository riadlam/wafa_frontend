import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrCodeDialog {
  static Future<void> show({
    required BuildContext context,
    required String email,
  }) async {
    // Ensure dialog is not opened multiple times
    if (ModalRoute.of(context)?.isCurrent == false) return;

    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'QR Code',
      barrierColor: Colors.black.withAlpha((0.6 * 255).toInt()),
      transitionDuration: const Duration(milliseconds: 450),
      pageBuilder: (context, anim1, anim2) {
        return const SizedBox.shrink(); // Actual UI is in transitionBuilder
      },
      transitionBuilder: (context, anim1, anim2, child) {
        final scale = Curves.easeOutBack.transform(anim1.value);
        final opacity = anim1.value;
        final slide = Tween<Offset>(
          begin: const Offset(0, 0.15),
          end: Offset.zero,
        ).transform(anim1.value);
        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, slide.dy * 60),
            child: Transform.scale(
              scale: scale,
              child: Center(
                child: Material(
                  color: Colors.transparent,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final maxQrSize = (constraints.maxWidth < constraints.maxHeight
                          ? constraints.maxWidth
                          : constraints.maxHeight) * 0.55;
                      return Container(
                        constraints: const BoxConstraints(
                          minWidth: 320,
                          maxWidth: 420,
                          minHeight: 320,
                          maxHeight: 600,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(36),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha((0.18 * 255).toInt()),
                              blurRadius: 40,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Your QR Code',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 28),
                            _PulsingQr(
                              email: email,
                              size: maxQrSize > 340 ? 340 : maxQrSize,
                            ),
                            const SizedBox(height: 28),
                            Text(
                              email,
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 22),
                            ElevatedButton.icon(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.close),
                              label: const Text(
                                'Close',
                                style: TextStyle(fontSize: 20),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF5003),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 38, vertical: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PulsingQr extends StatefulWidget {
  final String email;
  final double size;
  const _PulsingQr({required this.email, required this.size});

  @override
  State<_PulsingQr> createState() => _PulsingQrState();
}

class _PulsingQrState extends State<_PulsingQr> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final pulse = 1.0 + 0.08 * _controller.value;
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF5003).withAlpha((0.18 * 255).toInt()),
                blurRadius: 48 * pulse,
                spreadRadius: 8 * pulse,
              ),
            ],
          ),
          child: Transform.scale(
            scale: pulse,
            child: Semantics(
              label: 'QR Code for your email',
              child: QrImageView(
                data: widget.email,
                version: QrVersions.auto,
                size: widget.size,
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                gapless: true,
                errorCorrectionLevel: QrErrorCorrectLevel.H,
              ),
            ),
          ),
        );
      },
    );
  }
}
