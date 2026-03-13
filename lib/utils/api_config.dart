class ApiConfig {
  static const String baseUrl = 'http://103.57.178.66:9005';
  static const String apiUrl = '$baseUrl/api';
  static const String login = '$apiUrl/login';
  static const String register = '$apiUrl/register';
  static const String logout = '$apiUrl/logout';
  static const String userProfile = '$apiUrl/user';

  // --- NEW ADMIN ROUTES ---
  static const String adminDashboardData = '$apiUrl/admin/dashboard';
  static const String reviewUser = '$apiUrl/admin/review-user';
  static const String toggleUserStatus = '$apiUrl/admin/toggle-user-status';

  static Map<String, String> getHeaders([String? token]) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}