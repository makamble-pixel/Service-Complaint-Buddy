import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:scb/config/api_config.dart';
import 'package:scb/screens/complaint_detail_page.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'homepg.dart';

class ComplaintHistoryPage extends StatefulWidget {
  const ComplaintHistoryPage({super.key});

  @override
  _ComplaintHistoryPageState createState() => _ComplaintHistoryPageState();
}

class _ComplaintHistoryPageState extends State<ComplaintHistoryPage> {
  List<dynamic> _complaints = [];
  bool _isLoading = true;
  String? _email;

  @override
  void initState() {
    super.initState();
    _fetchComplaints();
  }

  Future<void> _fetchComplaints() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    setState(() {
      _email = email; // Store the email
    });
    final response = await http.get(
      Uri.parse('$baseUrl/api/complaints/status?email=$email'),
    );

    if (response.statusCode == 200) {
      setState(() {
        _complaints = json.decode(response.body);
        _isLoading = false;
      });
    } else {
      // Handle error
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _onWillPop() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
    return false; // Prevent the default back button action
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Your Complaints'),
        ),
        body: _email == null
            ? const Center(child: CircularProgressIndicator())
            : _complaints.isEmpty
                ? const Center(child: Text('No complaints found'))
                : ListView.builder(
                    itemCount: _complaints.length,
                    itemBuilder: (context, index) {
                      final complaint = _complaints[index];
                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 16),
                        child: ListTile(
                          title: Text(complaint[
                              'appliance']), // Change 'appliance' as needed
                          subtitle: Text('Status: ${complaint['status']}'),
                          onTap: () {
                            // Redirect to the tracking screen for the specific complaint
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => (ComplaintDetailPage(
                                      complaintId: complaint['id']))),
                            );
                          },
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
