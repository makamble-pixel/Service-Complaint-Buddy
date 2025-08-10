import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ComplaintDetailPage extends StatefulWidget {
  final int complaintId;

  const ComplaintDetailPage({super.key, required this.complaintId});

  @override
  _ComplaintDetailPageState createState() => _ComplaintDetailPageState();
}

class _ComplaintDetailPageState extends State<ComplaintDetailPage> {
  late Future<Map<String, dynamic>> _complaint;
  String _name = '';
  String _email = '';
  String _phone = '';

  @override
  void initState() {
    super.initState();
    _loadProfileInfo();
    _complaint = fetchComplaintDetails(widget.complaintId);
  }

  Future<void> _loadProfileInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final profileInfo = prefs.getString('profileInfo');
    if (profileInfo != null) {
      final data = jsonDecode(profileInfo);
      setState(() {
        _name = data['name'] ?? 'name not available';
        _email = data['email'] ?? 'email not available';
        _phone = data['phone'] ?? 'number not available';
      });
    }
  }

  Future<Map<String, dynamic>> fetchComplaintDetails(int complaintId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/api/complaints/$complaintId'));

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load complaint details');
    }
  }

  Future<void> _updateComplaintStatus(int complaintId, String status) async {
    final response = await http.put(
      Uri.parse('$baseUrl/update-complaint/$complaintId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'status': status,
        'assigned_to': '$_name, $_email, $_phone',
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Job status updated successfully!')));
      Navigator.pop(context); // Go back to the previous screen
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update job status.')));
    }
  }

  void _showTakeJobConfirmationDialog(int complaintId, String description) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Take Job'),
          content: Text('Do you want to take the job: "$description"?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () async {
                await _updateComplaintStatus(
                    complaintId, 'pending'); // Update status to pending
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void _showCompletionConfirmationDialog(int complaintId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Job Completion Confirmation'),
          content: const Text('Is the job completed?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () async {
                await _updateComplaintStatus(
                    complaintId, 'completed'); // Update status to completed
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Complaint Details',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.grey[800], // Dark grey color for AppBar
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _complaint,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final complaint = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Table(
                    columnWidths: const {
                      0: FlexColumnWidth(1), // Title Column
                      1: FlexColumnWidth(2), // Value Column
                    },
                    border: TableBorder.all(
                      color: Colors.white, // Table border color
                      width: 0.0, // Border width
                    ),
                    children: [
                      _buildTableRow(
                          'Complaint ID', complaint['id']?.toString() ?? 'N/A'),
                      _buildTableRow(
                          'Customer Name', complaint['name'] ?? 'N/A'),
                      _buildTableRow(
                          'Description', complaint['description'] ?? 'N/A'),
                      _buildTableRow('Status', complaint['status'] ?? 'N/A'),
                      _buildTableRow('Product', complaint['product'] ?? 'N/A'),
                      _buildTableRow('Brand', complaint['brand'] ?? 'N/A'),
                      _buildTableRow(
                          'Date Registered', complaint['created_at'] ?? 'N/A'),
                      _buildTableRow(
                        'Address',
                        '${complaint['address'] ?? ''}, ${complaint['city'] ?? ''}, '
                            '${complaint['state'] ?? ''}, ${complaint['postal_code'] ?? ''}',
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (complaint['status'] == 'pending')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          _showCompletionConfirmationDialog(complaint['id']);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.grey[600], // Grey color for button
                        ),
                        child: const Text(
                          'Mark Job as Completed',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                  else if (complaint['status'] == 'accepted')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          _showTakeJobConfirmationDialog(
                              complaint['id'], complaint['description'] ?? '');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.grey[600], // Grey color for button
                        ),
                        child: const Text(
                          'Take Job',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  TableRow _buildTableRow(String title, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(value),
        ),
      ],
    );
  }
}