import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/auth_screen.dart';
import 'screens/change_password_screen.dart';
import 'providers/auth_provider.dart';
import 'customer/home_screen.dart';

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
          // Display the appropriate screen based on the auth state
          if (authProvider.isLoading) {
            return const MaterialApp(
              home: Scaffold(
                body: Center(
                  child:
                      CircularProgressIndicator(), // Simple loading indicator
                ),
              ),
            );
          }
          // After loading, show either the HomePg or AuthScreen based on the auth state
          return MaterialApp(
            debugShowCheckedModeBanner: false, // Disable the debug banner
            home: const AuthScreen(),
            routes: {
              '/login': (context) => const AuthScreen(),
              '/register': (context) => const AuthScreen(),
              '/home': (context) => const HomePage(),
              //'/changePassword': (context) => ChangePasswordScreen(),
            },
          );
        },
      ),
    );
  }
}