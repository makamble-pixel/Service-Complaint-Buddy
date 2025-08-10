import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'trackingscreen.dart'; // Import the ComplaintTrackingScreen

class ComplaintPage extends StatefulWidget {
  const ComplaintPage({super.key});

  @override
  _ComplaintPageState createState() => _ComplaintPageState();
}

class _ComplaintPageState extends State<ComplaintPage> {
  String? _email;

  @override
  void initState() {
    super.initState();
    _loadEmailAndFetchComplaints();
  }

  // Load email from SharedPreferences and fetch complaints
  Future<void> _loadEmailAndFetchComplaints() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    
    if (email != null) {
      setState(() {
        _email = email;
      });
      await Provider.of<AuthProvider>(context, listen: false).fetchComplaints(email);
    }
  }

  @override
  Widget build(BuildContext context) {
    final complaints = Provider.of<AuthProvider>(context).complaints;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Complaints'),
      ),
      body: _email == null
          ? const Center(child: CircularProgressIndicator())
          : complaints.isEmpty
              ? const Center(child: Text('No complaints found'))
              : ListView.builder(
                  itemCount: complaints.length,
                  itemBuilder: (context, index) {
                    final complaint = complaints[index];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      child: ListTile(
                        title: Text(complaint['appliance']),
                        subtitle: Text('Status: ${complaint['status']}'),
                        onTap: () {
                          // Redirect to the tracking screen for the specific complaint
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ComplaintTrackingScreen(
                                complaintId: complaint['id'].toString(), // Assuming you have an 'id' field
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}