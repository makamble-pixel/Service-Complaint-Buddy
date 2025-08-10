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
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load complaint details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaint Details'),
        backgroundColor: Colors.grey[100],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _complaint,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final complaint = snapshot.data!;
            final assignedTo = complaint['assigned_to'];

            final technicianDetails =
                assignedTo != null ? assignedTo.split(',') : [];

            final technicianName = technicianDetails.isNotEmpty
                ? technicianDetails[0]
                : 'Not assigned';
            final technicianEmail = technicianDetails.length > 1
                ? technicianDetails[1]
                : 'Not available';
            final technicianPhone = technicianDetails.length > 2
                ? technicianDetails[2]
                : 'Not available';

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Complaint Information
                  _buildTableSection([
                    ['Complaint ID :', '${complaint['id']}'],
                    ['Customer Name :', '${complaint['name']}'],
                    ['Description :', '${complaint['description']}'],
                    ['Status :', '${complaint['status']}'],
                    ['Product :', '${complaint['product']}'],
                    ['Brand :', '${complaint['brand']}'],
                    ['Date Registered :', '${complaint['created_at']}'],
                    [
                      'Address :',
                      '${complaint['address']}, ${complaint['city']}, ${complaint['state']}, ${complaint['postal_code']}'
                    ],
                  ]),
                  const SizedBox(height: 24.0),

                  // Technician Information
                  const Text(
                    'Technician Details',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                  ),
                  const SizedBox(height: 8.0),
                  _buildTableSection([
                    ['Technician Name:', technicianName],
                    ['Technician Email :', technicianEmail],
                    ['Technician Phone :', technicianPhone],
                  ]),

                  const Spacer(),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No complaint details available.'));
          }
        },
      ),
    );
  }

  Widget _buildTableSection(List<List<String>> data) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(3),
      },
      border: TableBorder(
        horizontalInside: BorderSide(width: 0.5, color: Colors.grey[300]!),
      ),
      children: data
          .map(
            (row) => TableRow(
              children: row.map((cell) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    cell,
                    style: const TextStyle(fontSize: 14.0),
                  ),
                );
              }).toList(),
            ),
          )
          .toList(),
    );
  }
}
