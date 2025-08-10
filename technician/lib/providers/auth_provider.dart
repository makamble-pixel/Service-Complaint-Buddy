import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isAuthenticated = false;
  bool _isOtpVerified = false;
  bool _isOtpSent = false;
  String? _token;
  final bool _isLoadingComplaints = false;
  bool _isLoading = true; // New loading flag
  final List<dynamic> _complaints = [];

  // Getter for complaints
  List<dynamic> get complaints => _complaints;
  bool get isAuthenticated => _isAuthenticated;
  bool get isOtpVerified => _isOtpVerified;
  bool get isOtpSent => _isOtpSent;
  bool get isLoading => _isLoading; // Getter for loading state
  String? get token => _token;
  bool get isLoadingComplaints => _isLoadingComplaints;


  AuthProvider() {
    // Check authentication status when the provider is initialized
    //checkAuthStatus();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    _isAuthenticated = _token != null;
    _isLoading = false; // Set loading to false once check is done
    notifyListeners();
  }

  Future<void> login(String token, String email) async {
    try {
      _token = token;
      _isAuthenticated = true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setString('email', email); // Save the email
      notifyListeners();
    } catch (e) {
      // Handle errors (e.g., logging or showing an error message)
      print('Login error: $e');
    }
  }

  Future<void> checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('auth_token');
      _isAuthenticated = _token != null;
      notifyListeners();
    } catch (e) {
      // Handle errors (e.g., logging or showing an error message)
      print('Check Auth Status error: $e');
    }
  }

  Future<void> verifyotp() async {
    _isOtpVerified = true;
    notifyListeners();
  }

  Future<void> verifyForgotPasswordOTP() async {
    _isOtpVerified = true;
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      _isAuthenticated = false;
      _isOtpVerified = false;
      _token = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      notifyListeners();
    } catch (e) {
      // Handle errors (e.g., logging or showing an error message)
      print('Logout error: $e');
    }
  }
  // Method to send OTP for password reset
  Future<void> sendOtp(String email) async {
    _isLoading = true;
    notifyListeners();
    try {
      final result = await AuthService.sendOtp(email);
      if (result == 'OTP sent') {
        _isOtpSent = true;
      }
    } catch (e) {
      print('Error sending OTP: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /*// Method to verify OTP for password reset
  Future<void> verifyOTP(String email, String otp) async {
    _isLoading = true;
    notifyListeners();
    try {
      final isValid = await AuthService.verifyForgotPasswordOTP(email, otp);
      if (isValid) {
        _isOtpVerified = true;
      }
    } catch (e) {
      print('Error verifying OTP: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }*/

  // Method to reset the password
  Future<void> resetPassword(
      String email, String newPassword, String confirmPassword) async {
    _isLoading = true;
    notifyListeners();
    try {
      final result = await AuthService.tc_resetPassword(email, newPassword, confirmPassword);
      if (result == 'Password changed') {
        _isOtpVerified = false; // Reset OTP verified status after password reset
      }
    } catch (e) {
      print('Error resetting password: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}