import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:ui' as ui;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../../services/qr_scan_service.dart';
import '../../../../models/qr_scan/qr_scan_models.dart';

class ScannerOverlay extends CustomPainter {
  final Color borderColor;

  ScannerOverlay({required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final centerX = width / 2;
    final centerY = height / 2;
    const scannerSize = 200.0;

    // Draw background with opacity
    final backgroundPaint =
        Paint()
          ..color = Colors.black54
          ..style = PaintingStyle.fill;

    // Draw the background
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), backgroundPaint);

    // Create a path for the transparent center
    final path =
        Path()
          ..addRect(Rect.fromLTWH(0, 0, width, height))
          ..addRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                center: Offset(centerX, centerY),
                width: scannerSize,
                height: scannerSize,
              ),
              const Radius.circular(12),
            ),
          );

    // Draw the transparent center
    final centerPaint =
        Paint()
          ..color = Colors.transparent
          ..style = PaintingStyle.fill
          ..blendMode = ui.BlendMode.clear;

    canvas.drawPath(path, centerPaint);

    // Draw the border
    final borderPaint =
        Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.0;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX, centerY),
          width: scannerSize,
          height: scannerSize,
        ),
        const Radius.circular(12),
      ),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class QrCodeScreen extends StatefulWidget {
  const QrCodeScreen({super.key});

  @override
  State<QrCodeScreen> createState() => _QrCodeScreenState();
}

class _QrCodeScreenState extends State<QrCodeScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late final MobileScannerController _controller;
  late final AnimationController _animationController;
  final QRScanService _qrScanService = QRScanService();
  bool _isScanning = false;
  String? _lastScannedCode;
  bool _isFlashOn = false;
  bool _permissionGranted = false;
  bool _isProcessing = false; // Flag to prevent multiple scans of the same code
  final Set<String> _processedCodes = {}; // Track processed QR codes

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    WidgetsBinding.instance.addObserver(this);
    _checkCameraPermission();
    // Start with the camera running
    _startScanner();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _permissionGranted) {
      _startScanner();
    } else if (state == AppLifecycleState.paused) {
      _stopScanner();
    }
  }

  Future<void> _checkCameraPermission() async {
    final status = await Permission.camera.status;
    setState(() {
      _permissionGranted = status.isGranted;
    });

    if (!_permissionGranted) {
      final result = await _requestCameraPermission();
      if (!result) {
        if (mounted) {
          _showPermissionDeniedDialog();
        }
        return;
      }
    }
    _startScanner();
  }

  Future<bool> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    final isGranted = status.isGranted;
    setState(() {
      _permissionGranted = isGranted;
    });
    return isGranted;
  }

  Future<void> _startScanner() async {
    try {
      if (!_isScanning) {
        // Only start if not already scanning
        await _controller.start();
        if (mounted) {
          setState(() {
            _isScanning = true;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        // If the error is about the scanner already running, just update the state
        if (e.toString().contains('already started')) {
          setState(() {
            _isScanning = true;
          });
        } else {
          _showErrorDialog(
            'Camera Error',
            'Failed to start camera: ${e.toString()}',
          );
          setState(() {
            _isScanning = false;
          });
        }
      }
    }
  }

  Future<void> _stopScanner() async {
    try {
      if (_isScanning) {
        // Only stop if currently scanning
        await _controller.stop();
        if (mounted) {
          setState(() {
            _isScanning = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        // If the error is about the scanner not being started, just update the state
        if (e.toString().contains('not started')) {
          setState(() {
            _isScanning = false;
          });
        } else {
          _showErrorDialog(
            'Camera Error',
            'Failed to stop camera: ${e.toString()}',
          );
        }
      }
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (BuildContext context) => AlertDialog(
            title: const Text('Camera Permission Required'),
            content: const Text(
              'Camera permission is required to scan QR codes. Please enable it in app settings.',
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: const Text('Open Settings'),
                onPressed: () {
                  openAppSettings();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
    );
  }

  Future<void> _processQRCode(String email) async {
    if (!QRScanService.isValidEmail(email)) {
      if (mounted) {
        _showErrorDialog(
          'Invalid Email',
          'The scanned QR code does not contain a valid email address.',
        );
        setState(() => _isProcessing = false);
      }
      return;
    }

    try {
      final response = await _qrScanService.processQRScan(email);
      _processedCodes.add(email);
      if (mounted) {
        await _showScanResult(response);
        // Remove the code after showing the result to allow rescanning
        _processedCodes.remove(email);
      }
    } on QRScanException catch (e) {
      if (mounted) {
        _showErrorDialog('Error', e.message);
        // Remove the code if there was an error to allow rescanning
        _processedCodes.remove(email);
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Error', 'An unexpected error occurred');
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _onDetect(BarcodeCapture capture) {
    if (capture.barcodes.isEmpty || _isProcessing) return;

    final barcode = capture.barcodes.first;
    final code = barcode.rawValue;

    if (code != null && !_processedCodes.contains(code)) {
      setState(() {
        _isProcessing = true;
        _lastScannedCode = code;
      });
      _processQRCode(code);
    }
  }

  Future<void> _showScanResult(QRScanResponse response) async {
    await showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext context) {
        final data = response.data;
        final userCard = data.userLoyaltyCard;
        final loyaltyCard = userCard.loyaltyCard;

        return AlertDialog(
          title: const Text(
            'Stamp Added Successfully!',
            style: TextStyle(color: Colors.green),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Image.network(
                    loyaltyCard.logoUrl,
                    height: 80,
                    errorBuilder:
                        (context, error, stackTrace) => const Icon(
                          Icons.store,
                          size: 60,
                          color: Colors.blue,
                        ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  data.broadcastedMessage,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Divider(),
                _buildInfoRow(
                  'Current Stamps',
                  '${userCard.activeStamps} / ${loyaltyCard.totalStamps}',
                ),
                _buildInfoRow('Status', response.message),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100, // Fixed width for the label
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8.0), // Add some spacing between label and value
          Expanded(
            child: Text(
              value,
              maxLines: 2, // Limit to 2 lines
              overflow: TextOverflow.ellipsis, // Show ellipsis if text is too long
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleScan() async {
    if (_isScanning) {
      await _stopScanner();
    } else {
      await _startScanner();
    }
    if (mounted) {
      setState(() {
        _isScanning = !_isScanning;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleFlash() {
    setState(() {
      _isFlashOn = !_isFlashOn;
      _controller.toggleTorch();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Code Scanner'), centerTitle: true),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child:
                !_permissionGranted
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.camera_alt,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Camera permission is required to scan QR codes',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _checkCameraPermission,
                            child: const Text('Grant Permission'),
                          ),
                        ],
                      ),
                    )
                    : _isScanning
                    ? Stack(
                      children: [
                        MobileScanner(
                          controller: _controller,
                          onDetect: _onDetect,
                          errorBuilder: (context, error, child) {
                            return Center(
                              child: Text(
                                'Camera Error: ${error.toString()}',
                                style: const TextStyle(color: Colors.red),
                              ),
                            );
                          },
                        ),
                        if (_isScanning)
                          const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SpinKitCircle(color: Colors.white, size: 50.0),
                                SizedBox(height: 16),
                                Text(
                                  'Scanning for email QR codes...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        CustomPaint(
                          painter: ScannerOverlay(
                            borderColor: Theme.of(context).primaryColor,
                          ),
                        ),
                        Positioned(
                          top: 16,
                          right: 16,
                          child: IconButton(
                            icon: Icon(
                              _isFlashOn ? Icons.flash_on : Icons.flash_off,
                              color: Colors.white,
                              size: 30,
                            ),
                            onPressed: _toggleFlash,
                          ),
                        ),
                      ],
                    )
                    : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.qr_code_scanner,
                            size: 100,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Tap the button below to start scanning',
                            style: TextStyle(fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
          ),
          if (_lastScannedCode != null && _processedCodes.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Last scanned: ${_lastScannedCode}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
