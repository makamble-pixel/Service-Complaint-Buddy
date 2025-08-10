import 'package:flutter/material.dart';
import '/services/auth_service.dart';
import 'reset_password.dart';

class OTPVerifyScreen extends StatefulWidget {
  final String email;

  const OTPVerifyScreen({super.key, required this.email});

  @override
  _OTPVerifyScreenState createState() => _OTPVerifyScreenState();
}

class _OTPVerifyScreenState extends State<OTPVerifyScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  void _verifyOtp() async {
    setState(() {
      _isLoading = true;
    });

    final response = await AuthService.verifyForgotPasswordOTP(
        widget.email, _otpController.text);
    print('OTP verification response: $response'); // Debug statement

    if (response) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => ResetPasswordScreen(email: widget.email)),
      );
    } else {
      setState(() {
        _error = 'Invalid OTP';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP'),
        backgroundColor: const Color(0xFF795548), // Dark brown AppBar
      ),
      body: Center(
        // Center the content
        child: SingleChildScrollView(
          // Allows scrolling on smaller screens
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center, // Center items vertically
            children: [
              const Text(
                'Enter the 6-digit OTP sent to your email:',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.brown, // Use a contrasting color for text
                ),
                textAlign: TextAlign.center, // Center the text
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _otpController,
                decoration: InputDecoration(
                  labelText: 'OTP',
                  errorText: _error,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0), // Rounded corners
                    borderSide:
                        const BorderSide(color: Colors.brown), // Border color
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: Colors.brown),
                  ),
                ),
                keyboardType: TextInputType.number,
                maxLength: 6, // Limit to 6 digits
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _verifyOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF795548), // Brown button color
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(8.0), // Rounded button
                        ),
                      ),
                      child: const Text(
                        'Verify OTP',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
