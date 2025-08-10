import 'package:admin/api_config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PendingComplaintsPage extends StatefulWidget {
  const PendingComplaintsPage({super.key});

  @override
  _PendingComplaintsPageState createState() => _PendingComplaintsPageState();
}

class _PendingComplaintsPageState extends State<PendingComplaintsPage> {
  List<dynamic> pendingComplaints = [];
  bool isLoading = true; // State to manage loading

  @override
  void initState() {
    super.initState();
    fetchPendingComplaints();
  }

  // Method to fetch complaints from the backend
  Future<void> fetchPendingComplaints() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/complaints/pending'), // Use your backend URL
      );

      if (response.statusCode == 200) {
        final List<dynamic> complaintsData = json.decode(response.body);
        setState(() {
          pendingComplaints = complaintsData;
          isLoading = false; // Stop showing the loader
        });
      } else {
        print('Failed to load complaints: ${response.statusCode}');
        setState(() {
          isLoading = false; // Stop loader in case of error
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false; // Stop loader on error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator()) // Show loader while fetching data
          : pendingComplaints.isEmpty
              ? const Center(child: Text('No pending complaints available'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.builder(
                    itemCount: pendingComplaints.length,
                    itemBuilder: (context, index) {
                      final complaint = pendingComplaints[index];

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
                                "Email: ${complaint['email']}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Address: ${complaint['address']}, ${complaint['city']}, ${complaint['state']} ${complaint['zip']}",
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
                                "Complaints Details: ${complaint['description']}",
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
                              const SizedBox(height: 4),
                              Text(
                                "Status: ${complaint['status']}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      showApproveDialog(complaint['id']);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueAccent,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text(
                                      'Approve',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  ElevatedButton(
                                    onPressed: () {
                                      showRejectDialog(complaint['id']);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text(
                                      'Reject',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
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

  // Show Approve Dialog
  void showApproveDialog(int complaintId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Complaint'),
        content: const Text('Do you want to approve this complaint?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
            },
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              approveComplaint(complaintId); // Approve the complaint
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  // Show Reject Dialog
  void showRejectDialog(int complaintId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Complaint'),
        content: const Text('Do you want to reject this complaint?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
            },
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              rejectComplaint(complaintId); // Reject the complaint
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  // Approve complaint to engineer
  void approveComplaint(int complaintId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/complaints/approve'), // Backend URL
        body: jsonEncode({'complaintId': complaintId}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print('Complaint forwarded successfully');
        // Refresh complaints list
        fetchPendingComplaints();
      } else {
        print('Failed to forward complaint: ${response.statusCode}');
      }
    } catch (e) {
      print('Error forwarding complaint: $e');
    }
  }

  // Reject complaint
  void rejectComplaint(int complaintId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/complaints/rejectComplaint'), // Backend URL
        body: jsonEncode({'complaintId': complaintId}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print('Complaint rejected successfully');
        setState(() {
          pendingComplaints
              .removeWhere((complaint) => complaint['id'] == complaintId);
        });
      } else {
        print('Failed to reject complaint: ${response.statusCode}');
      }
    } catch (e) {
      print('Error rejecting complaint: $e');
    }
  }
}
