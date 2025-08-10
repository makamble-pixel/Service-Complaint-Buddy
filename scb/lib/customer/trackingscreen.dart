import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:scb/config/api_config.dart';

import '../screens/complaint_detail_page.dart';

class ComplaintTrackingScreen extends StatefulWidget {
  final String complaintId;

  const ComplaintTrackingScreen({super.key, required this.complaintId});

  @override
  _ComplaintTrackingScreenState createState() =>
      _ComplaintTrackingScreenState();
}

class _ComplaintTrackingScreenState extends State<ComplaintTrackingScreen> {
  Map<String, dynamic>? complaint;
  String technicianName = '';
  String technicianEmail = '';
  String technicianPhone = '';

  Future<void> fetchComplaintDetails(String complaintId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/api/complaints/$complaintId'));

    if (response.statusCode == 200) {
      setState(() {
        complaint = json.decode(response.body);
        if (complaint!['assigned_to'] != null &&
            complaint!['assigned_to'].contains(',')) {
          final assignedToParts = complaint!['assigned_to'].split(',');
          technicianName = assignedToParts[0].trim();
          technicianEmail = assignedToParts[1].trim();
          technicianPhone = assignedToParts[2].trim();
        }
      });
    } else {
      setState(() {
        complaint = null; // Handle error or null state
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchComplaintDetails(widget
        .complaintId); // Fetch complaint details when the screen initializes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaint Tracking'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // Back navigation
          },
        ),
      ),
      body: complaint == null
          ? const Center(
              child: CircularProgressIndicator()) // Show loading indicator
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Complaint Status Tracker (appears at the top)
                  ComplaintStatusTracker(complaintStatus: complaint!['status']),

                  const SizedBox(height: 20),

                  // View Details Button
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // Redirect to the tracking screen for the specific complaint
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ComplaintDetailPage(
                                complaintId: complaint!['id']),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 10),
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'View Details',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class ComplaintStatusTracker extends StatelessWidget {
  final String complaintStatus;

  const ComplaintStatusTracker({super.key, required this.complaintStatus});

  @override
  Widget build(BuildContext context) {
    List<Step> steps = [];

    // Step: Complaint Registered
    steps.add(
      const Step(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Complaint Registered',
                style: TextStyle(fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Text('Your complaint has been successfully registered.',
            style: TextStyle(fontSize: 14)),
        isActive: true,
        state: StepState.complete,
      ),
    );

    // Step: Complaint Rejected
    if (complaintStatus == 'rejected') {
      steps.add(
        Step(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.blue),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Complaint Rejected',
                  style: TextStyle(fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: const Text('Your complaint has been rejected.',
              style: TextStyle(fontSize: 14)),
          isActive: complaintStatus == 'rejected',
          state: StepState.complete,
        ),
      );
    }

    // Step: Complaint Accepted
    if (complaintStatus == 'accepted' ||
        complaintStatus == 'pending' ||
        complaintStatus == 'completed') {
      steps.add(
        Step(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.blue),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Complaint Accepted',
                  style: TextStyle(fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: const Text(
              'Your complaint has been accepted for processing.',
              style: TextStyle(fontSize: 14)),
          isActive: complaintStatus == 'accepted' ||
              complaintStatus == 'pending' ||
              complaintStatus == 'completed',
          state: StepState.complete,
        ),
      );
    }

    // Step: Complaint Pending
    if (complaintStatus == 'pending' || complaintStatus == 'completed') {
      steps.add(
        Step(
          title: const Row(
            children: [
              Icon(Icons.pending, color: Colors.orange),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Complaint Pending',
                  style: TextStyle(fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: const Text('Your complaint is currently pending.',
              style: TextStyle(fontSize: 14)),
          isActive:
              complaintStatus == 'pending' || complaintStatus == 'completed',
          state: StepState.complete,
        ),
      );
    }

    // Step: Complaint Completed
    if (complaintStatus == 'completed') {
      steps.add(
        const Step(
          title: Row(
            children: [
              Icon(Icons.done, color: Colors.blue),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Complaint Completed',
                  style: TextStyle(fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: Text('Your complaint has been resolved successfully.',
              style: TextStyle(fontSize: 14)),
          isActive: true,
          state: StepState.complete,
        ),
      );
    }

    return Column(
      children: [
        Stepper(
          key: ValueKey(steps.length), // Add a unique key based on steps length
          type: StepperType.vertical,
          currentStep: steps.length - 1,
          controlsBuilder: (BuildContext context, ControlsDetails controls) {
            return const SizedBox.shrink(); // Hide the controls
          },
          steps: steps,
        ),
        const SizedBox(height: 20),
        Text(
          'Current Status: $complaintStatus',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
