class ApiConfig {
  static const String baseUrl = 'http://192.168.0.108:9005';
  static const String apiUrl = '$baseUrl/api';
  static const String login = '$apiUrl/login';
  static const String register = '$apiUrl/register';
  static const String logout = '$apiUrl/logout';
  static const String userProfile = '$apiUrl/user';

  static Map<String, String> getHeaders([String? token]) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}