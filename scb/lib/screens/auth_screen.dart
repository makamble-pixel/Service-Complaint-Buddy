import 'package:flutter/material.dart';
import 'package:scb/customer/homepg.dart';
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
      // Remove AppBar to create a more minimalistic splash-screen-like experience
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: const BoxDecoration(color: Color(0xFF795548)),
        child: Center(
          child/*: authProvider.isAuthenticated
              ? HomePage() // Navigate to HomePage if authenticated
              */: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // App Logo or Icon (Optional)
                    const Icon(
                      Icons.build_rounded, // Appliance repair-related icon
                      size: 100,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 30),
                    // Welcome Text
                    const Text(
                      'Welcome to Service Complaint Buddy',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Are you already registered?',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Login Button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white, // White button
                        foregroundColor: const Color(0xFFB3541E), // Rust text color
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text('Login'),
                    ),
                    const SizedBox(height: 20),
                    // Register Button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const RegisterScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.transparent, // Transparent button
                        foregroundColor: Colors.white, // White text color
                        side: const BorderSide(
                            color: Colors.white, width: 2), // White border
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text('Register'),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
