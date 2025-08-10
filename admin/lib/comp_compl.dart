import 'package:admin/api_config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CompletedComplaintsPage extends StatefulWidget {
  const CompletedComplaintsPage({super.key});

  @override
  _CompletedComplaintsPageState createState() =>
      _CompletedComplaintsPageState();
}

class _CompletedComplaintsPageState extends State<CompletedComplaintsPage> {
  List<dynamic> completedComplaints = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCompletedComplaints();
  }

  // Method to fetch completed complaints from the backend
  Future<void> fetchCompletedComplaints() async {
    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/api/complaints/completed'), // Replace with your backend URL
      );

      if (response.statusCode == 200) {
        final List<dynamic> complaintsData = json.decode(response.body);
        setState(() {
          completedComplaints = complaintsData;
          isLoading = false;
        });
      } else {
        print('Failed to load completed complaints: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : completedComplaints.isEmpty
              ? const Center(child: Text('No completed complaints available'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.builder(
                    itemCount: completedComplaints.length,
                    itemBuilder: (context, index) {
                      final complaint = completedComplaints[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Customer: ${complaint['name']}",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Address: ${complaint['address']}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Appliance: ${complaint['appliance']}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "In Warranty: ${complaint['underwarranty'] ? 'Yes' : 'No'}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Brand: ${complaint['brand']}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Registered Date: ${complaint['created_at']}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}