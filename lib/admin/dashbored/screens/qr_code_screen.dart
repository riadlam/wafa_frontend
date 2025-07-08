import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:ui' as ui;

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
    final backgroundPaint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;
    
    // Draw the background
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), backgroundPaint);

    // Create a path for the transparent center
    final path = Path()
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
    final centerPaint = Paint()
      ..color = Colors.transparent
      ..style = PaintingStyle.fill
      ..blendMode = ui.BlendMode.clear;

    canvas.drawPath(path, centerPaint);

    // Draw the border
    final borderPaint = Paint()
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

class _QrCodeScreenState extends State<QrCodeScreen> with WidgetsBindingObserver {
  MobileScannerController controller = MobileScannerController();
  bool isScanning = false;
  String? scannedResult;
  bool isFlashOn = false;
  bool _permissionGranted = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkCameraPermission();
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
      await controller.start();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Failed to start camera', e.toString());
      }
    }
  }

  Future<void> _stopScanner() async {
    try {
      await controller.stop();
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Camera Error', 'Failed to stop camera');
      }
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Camera Permission Required'),
        content: const Text(
            'Camera permission is required to scan QR codes. Please enable it in app settings.'),
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
      builder: (BuildContext context) => AlertDialog(
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

  void _onDetect(BarcodeCapture capture) {
    if (capture.barcodes.isNotEmpty) {
      final barcode = capture.barcodes.first;
      if (barcode.rawValue != null) {
        setState(() {
          scannedResult = barcode.rawValue!;
          isScanning = false;
        });
        if (scannedResult != null) {
          _showScanResult(scannedResult!);
        }
      }
    }
  }

  void _showScanResult(String result) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Scan Result'),
          content: Text(result),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _toggleScan() {
    setState(() {
      isScanning = !isScanning;
      if (!isScanning) {
        scannedResult = null;
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopScanner();
    controller.dispose();
    super.dispose();
  }

  void _toggleFlash() {
    setState(() {
      isFlashOn = !isFlashOn;
      controller.toggleTorch();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Scanner'),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: !_permissionGranted
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.camera_alt, size: 64, color: Colors.grey),
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
                : !_isInitialized
                    ? const Center(child: CircularProgressIndicator())
                    : isScanning
                        ? Stack(
                            children: [
                              MobileScanner(
                                controller: controller,
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
                            isFlashOn ? Icons.flash_on : Icons.flash_off,
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: _toggleScan,
              icon: Icon(isScanning ? Icons.stop : Icons.qr_code_scanner),
              label: Text(isScanning ? 'Stop Scanning' : 'Start QR Scan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
          if (scannedResult != null && !isScanning)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Last Scanned: ${scannedResult!}'
                    .substring(0, 30) + 
                    (scannedResult!.length > 30 ? '...' : ''),
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
