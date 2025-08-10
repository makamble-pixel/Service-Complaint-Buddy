import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import 'complaint_detail_page.dart'; // Import the new page

class AcceptedComplaintsPage extends StatefulWidget {
  const AcceptedComplaintsPage({super.key});

  @override
  _AcceptedComplaintsPageState createState() => _AcceptedComplaintsPageState();
}

class _AcceptedComplaintsPageState extends State<AcceptedComplaintsPage> {
  late Future<List<dynamic>> _complaints;
  String _name = '';
  String _email = '';
  String _phone = '';

  @override
  void initState() {
    super.initState();
    _loadProfileInfo();
    _complaints = fetchAcceptedComplaints();
  }

  Future<void> _loadProfileInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileInfo = prefs.getString('profileInfo');

      if (profileInfo != null) {
        final data = jsonDecode(profileInfo);
        setState(() {
          _name = data['name'] ?? 'name not available';
          _email = data['email'] ?? 'email not available';
          _phone = data['phone'] ?? 'number not available';
        });
      } else {
        setState(() {
          _name = 'name not available';
          _email = 'email not available';
          _phone = 'number not available';
        });

        final defaultData = {
          'name': _name,
          'email': _email,
          'phone': _phone,
        };
        await prefs.setString('profileInfo', jsonEncode(defaultData));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading profile info: $e')),
      );

      setState(() {
        _name = 'name not available';
        _email = 'email not available';
        _phone = 'number not available';
      });

      final defaultData = {
        'name': _name,
        'email': _email,
        'phone': _phone,
      };
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profileInfo', jsonEncode(defaultData));
    }
  }

  Future<List<dynamic>> fetchAcceptedComplaints() async {
    final response =
        await http.get(Uri.parse('$baseUrl/api/complaints/accepted'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load complaints');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Padding(
      //     padding: const EdgeInsets.only(left: 16.0),
      //     child: Text(
      //       'Accepted Complaints',
      //       style: GoogleFonts.poppins(
      //         color: Colors.black,
      //       ),
      //     ),
      //   ),
      //   flexibleSpace: Container(
      //     decoration: const BoxDecoration(
      //       color: Colors.white,
      //       // gradient: LinearGradient(
      //       //   colors: [Colors.brown, Color.fromARGB(255, 67, 29, 15)],
      //       //   begin: Alignment.topLeft,
      //       //   end: Alignment.bottomRight,
      //       // ),
      //     ),
      //   ),
      // ),
      body: FutureBuilder<List<dynamic>>(
        future: _complaints,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final complaints = snapshot.data!;
            return ListView.builder(
              itemCount: complaints.length,
              padding: const EdgeInsets.all(16.0),
              itemBuilder: (context, index) {
                return _buildComplaintCard(
                  context,
                  complaints[index]['description'],
                  complaints[index]['status'],
                  complaints[index]['id'],
                );
              },
            );
          }
        },
      ),
    );
  }

  // Function to build individual complaint cards
  Widget _buildComplaintCard(BuildContext context, String description,
      String status, int complaintId) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 5,
      margin: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ComplaintDetailPage(complaintId: complaintId),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Icon(
                Icons.report_problem_rounded,
                size: 40,
                color: Colors.orangeAccent,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'Status: ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          status,
                          style: TextStyle(
                            fontSize: 14,
                            color: _getStatusColor(status),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to get status color dynamically
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Colors.green[600]!;
      case 'pending':
        return Colors.orangeAccent;
      case 'rejected':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }
}
