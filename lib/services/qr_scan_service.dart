import '../models/qr_scan/qr_scan_models.dart';
import 'api_client.dart';

class QRScanService {
  final ApiClient _apiClient = ApiClient();

  QRScanService();

  Future<QRScanResponse> processQRScan(String email) async {
    try {
      final response = await _apiClient.post(
        '/process-qr-scan',
        data: QRScanRequest(email: email).toJson(),
      );
      return QRScanResponse.fromJson(response);
    } catch (e) {
      throw QRScanException(
        message: e.toString(),
        statusCode: 500, // Default status code for unknown errors
      );
    }
  }

  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }
}

class QRScanException implements Exception {
  final String message;
  final int statusCode;

  QRScanException({required this.message, this.statusCode = 400});

  @override
  String toString() => 'QRScanException: $message (Status: $statusCode)';
}
