class ApiEndpoints {
  // Base URL
  static const String baseUrl = 'http://192.168.1.15:8000';
  static const String apiPrefix = '/api';

  // Auth endpoints
  static const String googleLogin = '$apiPrefix/login/google';
  static const String logout = '$apiPrefix/logout';
  
  // User endpoints
  static const String planInfo = '$apiPrefix/user/plan-info';
  
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
