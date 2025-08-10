import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scb/screens/change_password_screen.dart';
import 'screens/auth_screen.dart';
import 'customer/homepg.dart';
import 'package:scb/providers/auth_provider.dart';
import 'screens/splash_screen.dart'; // Import the SplashScreen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          // Show the splash screen first, then navigate to the appropriate page
          return MaterialApp(
            debugShowCheckedModeBanner: false, // Disable the debug banner
            home: SplashScreen(), // Show splash screen first
            routes: {
              '/login': (context) => const AuthScreen(),
              '/register': (context) => const AuthScreen(),
              '/home': (context) => const HomePage(),
              '/changePassword': (context) => const ChangePasswordScreen(),
            },
          );
        },
      ),
    );
  }
}
