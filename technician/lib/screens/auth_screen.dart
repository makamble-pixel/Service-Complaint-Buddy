import 'package:flutter/material.dart';
import '/customer/home_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor:
          Colors.grey[100], // Light grey background for subtle contrast
      // appBar: AppBar(
      //   title: const Text('Welcome'),
      //   backgroundColor:
      //       Colors.grey[850], // Darker grey for a sleek, professional header
      //   centerTitle: true, // Center the title for a balanced look
      //   elevation: 2, // Slight elevation for a shadow effect
      // ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 24.0), // Add horizontal padding for better layout
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Are you already registered?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold, // Make the text bold for emphasis
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800], // Dark grey for a sleek look
                padding: const EdgeInsets.symmetric(
                    vertical: 18), // Add more vertical padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      12), // Larger radius for modern rounded buttons
                ),
                elevation: 5, // Slight elevation for depth
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text(
                'Login',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white, // White text for contrast
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors
                    .grey[600], // Slightly lighter grey for the register button
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegisterScreen(),
                  ),
                );
              },
              child: const Text(
                'Register',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white, // White text for consistency
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}