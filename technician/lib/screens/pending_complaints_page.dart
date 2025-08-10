import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:technician/config/api_config.dart';
import 'dart:convert';
import 'complaint_detail_page.dart'; // Make sure to import your ComplaintDetailPage

class PendingComplaintsPage extends StatefulWidget {
  const PendingComplaintsPage({super.key});

  @override
  _PendingComplaintsPageState createState() => _PendingComplaintsPageState();
}

class _PendingComplaintsPageState extends State<PendingComplaintsPage> {
  late Future<List<Map<String, dynamic>>> _pendingComplaints;

  @override
  void initState() {
    super.initState();
    _pendingComplaints = fetchPendingComplaints();
  }

  Future<List<Map<String, dynamic>>> fetchPendingComplaints() async {
    final response =
        await http.get(Uri.parse('$baseUrl/api/complaints/status/pending'));

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse
          .map((complaint) => complaint as Map<String, dynamic>)
          .toList();
    } else {
      throw Exception('Failed to load pending complaints');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // Light grey background
      // appBar: AppBar(
      //   title: const Text(
      //     'Pending Complaints',
      //     style: TextStyle(color: Colors.black), // Black text for AppBar
      //   ),
      //   backgroundColor: Colors.white, // White background for AppBar
      //   elevation: 0, // No shadow for AppBar
      // ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _pendingComplaints,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final complaints = snapshot.data!;
            return ListView.builder(
              itemCount: complaints.length,
              itemBuilder: (context, index) {
                final complaint = complaints[index];
                return Card(
                  color: Colors.white, // White background for each card
                  margin: const EdgeInsets.all(8.0),
                  elevation: 2.0, // Light shadow for card
                  child: ListTile(
                    title: Text(
                      'Complaint ID: ${complaint['id']}',
                      style: const TextStyle(
                        color: Colors.black, // Black text for the title
                      ),
                    ),
                    subtitle: Text(
                      'Description: ${complaint['description']}',
                      style: TextStyle(
                        color: Colors.grey[700], // Dark grey subtitle
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.check,
                        color: Colors.black, // Black icon for trailing
                      ),
                      onPressed: () {
                        // Action to handle complaint acceptance (optional)
                      },
                    ),
                    onTap: () {
                      // Navigate to the detailed complaint view
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ComplaintDetailPage(complaintId: complaint['id']),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
