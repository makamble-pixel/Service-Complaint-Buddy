import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/change_password_screen.dart';
import '../screens/login_screen.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // Light grey background
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.black), // Black text for AppBar
        ),
        backgroundColor: Colors.white, // White AppBar background
        elevation: 1.0, // Slight elevation for a clean look
        iconTheme:
            const IconThemeData(color: Colors.black), // Black icons in AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              tileColor: Colors.white, // White background for each tile
              leading:
                  const Icon(Icons.lock, color: Colors.black), // Black icon
              title: const Text(
                'Change Password',
                style: TextStyle(
                  color: Colors.black, // Black text
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChangePasswordScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            const Divider(
              color: Colors.grey, // Grey divider for a sleek separation
              thickness: 1.0,
            ),
            const SizedBox(height: 10),
            ListTile(
              tileColor: Colors.white, // White background for each tile
              leading:
                  const Icon(Icons.logout, color: Colors.black), // Black icon
              title: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.black, // Black text
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                _showLogoutConfirmation(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[100], // Light grey background for dialog
          title: const Text(
            'Confirm Logout',
            style: TextStyle(color: Colors.black), // Black text for title
          ),
          content: const Text(
            'Are you sure you want to log out?',
            style:
                TextStyle(color: Colors.black87), // Dark grey text for content
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'No',
                style: TextStyle(color: Colors.grey), // Grey text for buttons
              ),
            ),
            TextButton(
              onPressed: () {
                _logout(context);
              },
              child: const Text(
                'Yes',
                style:
                    TextStyle(color: Colors.red), // Red text for "Yes" button
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userEmail');
    await prefs.remove('userToken');

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }
}
