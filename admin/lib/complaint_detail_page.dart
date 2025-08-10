import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ComplaintDetailPage extends StatefulWidget {
  final int complaintId;

  const ComplaintDetailPage({super.key, required this.complaintId});

  @override
  _ComplaintDetailPageState createState() => _ComplaintDetailPageState();
}

class _ComplaintDetailPageState extends State<ComplaintDetailPage> {
  late Future<Map<String, dynamic>> _complaint;
  final String _name = '';
  final String _email = '';
  final String _phone = '';

  @override
  void initState() {
    super.initState();
    _complaint = fetchComplaintDetails(widget.complaintId);
  }

  Future<Map<String, dynamic>> fetchComplaintDetails(int complaintId) async {
    final response = await http.get(Uri.parse('$baseUrl/api/complaints/$complaintId'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load complaint details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complaint Details')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _complaint,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final complaint = snapshot.data!;
            final assignedTo = complaint['assigned_to']; // String containing name, email, phone
            final technicianDetails = assignedTo.split(','); // Split the string

            // Ensure we have all the necessary details
            final technicianName = technicianDetails.isNotEmpty ? technicianDetails[0] : 'Not assigned';
            final technicianEmail = technicianDetails.length > 1 ? technicianDetails[1] : 'Not available';
            final technicianPhone = technicianDetails.length > 2 ? technicianDetails[2] : 'Not available';

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Complaint ID: ${complaint['id']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8.0),
                  Text('Customer Name: ${complaint['name']}'),
                  const SizedBox(height: 8.0),
                  Text('Description: ${complaint['description']}'),
                  const SizedBox(height: 8.0),
                  Text('Status: ${complaint['status']}'),
                  const SizedBox(height: 8.0),
                  Text('Product: ${complaint['product']}'),
                  const SizedBox(height: 8.0),
                  Text('Brand: ${complaint['brand']}'),
                  const SizedBox(height: 8.0),
                  Text('Date Registered: ${complaint['created_at']}'),
                  const SizedBox(height: 8.0),
                  Text('Address: ${complaint['address']}, ${complaint['city']}, ${complaint['state']}, ${complaint['postal_code']}'),
                  const SizedBox(height: 16.0),

                  // Technician Details
                  const Text('Technician Details', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8.0),
                  Text('Technician Name: $technicianName'),
                  Text('Technician Email: $technicianEmail'),
                  Text('Technician Phone: $technicianPhone'),
                  
                  const Spacer(),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}