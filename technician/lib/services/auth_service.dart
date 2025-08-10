import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl =
      'http://192.168.45.56:3000/technician'; // Replace with your base URL

  // Register method
  static Future<String?> tc_register(
      String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return 'OTP sent to your email';
      } else {
        return 'Registration failed: ${response.body}';
      }
    } catch (e) {
      return 'Error occurred: $e';
    }
  }

  // Verify OTP method
  static Future<bool> tc_verifyOTP(String email, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify-OTP'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'otp': otp,
        }),
      );

      print('Response status: ${response.statusCode}');
      print(
          'Response body: ${response.body}'); // Print response body for debugging

      if (response.statusCode == 400) {
        print('Error: ${response.body}');
      }

      return response.statusCode == 201;
    } catch (e) {
      print('Error occurred: $e');
      return false;
    }
  }

  //verifyotp for forgot password
  static Future<bool> tc_verifyForgotPasswordOTP(
      String email, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verifyForgotPasswordOTP'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'otp': otp,
        }),
      );

      print('Response status: ${response.statusCode}');
      print(
          'Response body: ${response.body}'); // Print response body for debugging

      // Check for success status code
      return response.statusCode == 200;
    } catch (e) {
      print('Error occurred: $e');
      return false;
    }
  }

  // Login method
  static Future<String?> tc_login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['token'];
      } else {
        print('Failed to login: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error occurred: $e');
      return null;
    }
  }

  // Change password method
  static Future<String?> tc_changePassword(String currentPassword,
      String newPassword, String confirmPassword) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      final response = await http.post(
        Uri.parse('$baseUrl/changePassword'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token', // Include the token in the header
        },
        body: jsonEncode(<String, String>{
          'currentPassword': currentPassword,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        }),
      );

      if (response.statusCode == 200) {
        return 'Password changed successfully';
      } else {
        return 'Change password failed: ${response.body}';
      }
    } catch (e) {
      return 'Error occurred: $e';
    }
  }

  // Send OTP
  static Future<String?> sendOtp(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/send-otp'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{'email': email}),
      );
      return response.statusCode == 200
          ? 'OTP sent to your email'
          : 'Failed to send OTP';
    } catch (e) {
      return 'Error occurred: $e';
    }
  }

  // Reset Password
  static Future<String?> tc_resetPassword(
      String email, String newPassword, String confirmPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reset-password'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        }),
      );
      return response.statusCode == 200
          ? 'Password reset successful'
          : 'Failed to reset password';
    } catch (e) {
      return 'Error occurred: $e';
    }
  }

  // Fetch profile info for technician
  Future<void> fetchAndSaveTechnicianProfile(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/technician/getTechnicianProfile'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final profileData = jsonDecode(response.body);

      // Save the profile data in SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('name', profileData['name']);
      await prefs.setString('email', profileData['email']);
      await prefs.setString('phone', profileData['phone']);
      await prefs.setString('address', profileData['address']);
      await prefs.setString('city', profileData['city']);
      await prefs.setString('state', profileData['state']);
      await prefs.setString('zip', profileData['zip']);
    } else {
      throw Exception('Failed to fetch profile');
    }
  }
}
