import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ComplaintStatusTracker extends StatefulWidget {
  final int complaintStatus; // Fetch the status dynamically

  const ComplaintStatusTracker({super.key, required this.complaintStatus});

  @override
  _ComplaintStatusTrackerState createState() => _ComplaintStatusTrackerState();
}

class _ComplaintStatusTrackerState extends State<ComplaintStatusTracker> {
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    // Set initial step, with safety to prevent overflow
    _currentStep =
        widget.complaintStatus.clamp(0, 2); // Make sure it's between 0 and 2
  }

  // Function to simulate dynamic status update from data source
  void _updateStep(int step) {
    if (step >= 0 && step <= 2) {
      // Prevent invalid step values
      setState(() {
        _currentStep = step;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Complaint Status Tracker',
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: Colors.blueGrey[800],
      ),
      body: SingleChildScrollView(
        // Wrapping in SingleChildScrollView to prevent overflow issues
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Appliance Icon and Type
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.wash,
                    size: 40,
                    color: Colors.blueGrey[700],
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Washing Machine Complaint',
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.blueGrey[700],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Stepper(
                type: StepperType.vertical,
                currentStep: _currentStep,
                onStepTapped: (step) => _updateStep(step),
                controlsBuilder:
                    (BuildContext context, ControlsDetails controls) {
                  // We are returning an empty widget to hide the stepper's default buttons (next, previous)
                  return const SizedBox
                      .shrink(); // You can customize this if needed
                },
                steps: [
                  Step(
                    title: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 10),
                        Text(
                          'Complaint Registered',
                          style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    content: Text(
                      'Your complaint has been successfully registered.',
                      style: GoogleFonts.poppins(
                        textStyle: const TextStyle(fontSize: 14),
                      ),
                    ),
                    isActive: _currentStep >= 0,
                    state: _currentStep >= 0
                        ? StepState.complete
                        : StepState.indexed,
                  ),
                  Step(
                    title: Row(
                      children: [
                        const Icon(Icons.engineering, color: Colors.orange),
                        const SizedBox(width: 10),
                        Text(
                          'Forwarded to Engineer',
                          style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    content: Text(
                      'Your complaint has been forwarded to the engineer.',
                      style: GoogleFonts.poppins(
                        textStyle: const TextStyle(fontSize: 14),
                      ),
                    ),
                    isActive: _currentStep >= 1,
                    state: _currentStep >= 1
                        ? StepState.complete
                        : StepState.indexed,
                  ),
                  Step(
                    title: Row(
                      children: [
                        const Icon(Icons.done, color: Colors.blue),
                        const SizedBox(width: 10),
                        Text(
                          'Complaint Resolved',
                          style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    content: Text(
                      'The engineer has resolved your complaint.',
                      style: GoogleFonts.poppins(
                        textStyle: const TextStyle(fontSize: 14),
                      ),
                    ),
                    isActive: _currentStep >= 2,
                    state: _currentStep >= 2
                        ? StepState.complete
                        : StepState.indexed,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Current Status: ${_currentStep == 0
                        ? 'Registered'
                        : _currentStep == 1
                            ? 'Forwarded to Engineer'
                            : 'Resolved'}',
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueGrey[900],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueGrey[800],
        child: const Icon(Icons.arrow_forward),
        onPressed: () {
          // Simulate status change (For example, after admin updates status)
          if (_currentStep < 2) {
            _updateStep(_currentStep + 1);
          }
        },
      ),
    );
  }
}