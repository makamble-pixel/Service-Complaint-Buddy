import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';

class ComplaintRegistrationForm extends StatefulWidget {
  const ComplaintRegistrationForm({super.key});

  @override
  _ComplaintRegistrationFormState createState() =>
      _ComplaintRegistrationFormState();
}

class _ComplaintRegistrationFormState extends State<ComplaintRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  bool _underWarranty = false;

  // Controllers for text fields
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _brandController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();

  // Appliance Dropdown values
  String? _selectedAppliance;
  final List<String> _applianceOptions = [
    'Washing Machine',
    'Air Conditioner',
    'Refrigerator',
    'Oven'
  ];

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // Load profile info from SharedPreferences
  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final profileInfo = prefs.getString('profileInfo');
    
    if (profileInfo != null) {
      final data = jsonDecode(profileInfo);
      setState(() {
        _nameController.text = data['name'] ?? '';
        _emailController.text = data['email'] ?? '';
        _phoneController.text = data['phone'] ?? '';
        _addressController.text = data['address'] ?? '';
        _cityController.text = data['city'] ?? '';
        _stateController.text = data['state'] ?? '';
        _zipController.text = data['zip'] ?? '';
      });
    }
  }

  Future<void> _submitComplaint() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      try {
        await Provider.of<AuthProvider>(context, listen: false).submitComplaint(
          name: _nameController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          appliance: _selectedAppliance ?? '',  // Use the selected appliance
          brand: _brandController.text,
          underWarranty: _underWarranty,
          description: _descriptionController.text,
          address: _addressController.text,
          city: _cityController.text,
          state: _stateController.text,
          zip: _zipController.text,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Complaint submitted successfully')),
        );
      } catch (e) {
        print('Error: $e');  // Print the error to the console
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit complaint: $e')),  // Display error message
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaint Registration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Personal Information Section
              _buildCard(
                title: 'Personal Information',
                children: [
                  _buildTextField(
                    label: 'Full Name',
                    controller: _nameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your full name';
                      }
                      return null;
                    },
                  ),
                  _buildTextField(
                    label: 'Email Address',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  _buildTextField(
                    label: 'Phone Number',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty || !RegExp(r'^\+?[0-9]{10,15}$').hasMatch(value)) {
                        return 'Please enter a valid phone number';
                      }
                      return null;
                    },
                  ),
                ],
              ),

              // Appliance Details Section
              _buildCard(
                title: 'Appliance Details',
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedAppliance,
                    decoration: const InputDecoration(labelText: 'Appliance Type'),
                    items: _applianceOptions.map((String appliance) {
                      return DropdownMenuItem<String>(
                        value: appliance,
                        child: Text(appliance),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedAppliance = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select an appliance type';
                      }
                      return null;
                    },
                  ),
                  _buildTextField(
                    label: 'Brand',
                    controller: _brandController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the brand';
                      }
                      return null;
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Is the appliance under warranty?'),
                    value: _underWarranty,
                    onChanged: (bool? value) {
                      setState(() {
                        _underWarranty = value ?? false;
                      });
                    },
                  ),
                ],
              ),

              // Complaint Details Section
              _buildCard(
                title: 'Complaint Details',
                children: [
                  _buildTextField(
                    label: 'Issue Description',
                    controller: _descriptionController,
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please describe the issue';
                      }
                      return null;
                    },
                  ),
                ],
              ),

              // Address Information Section
              _buildCard(
                title: 'Address Information',
                children: [
                  _buildTextField(
                    label: 'Address',
                    controller: _addressController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your address';
                      }
                      return null;
                    },
                  ),
                  _buildTextField(
                    label: 'City',
                    controller: _cityController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your city';
                      }
                      return null;
                    },
                  ),
                  _buildTextField(
                    label: 'State/Province',
                    controller: _stateController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your state or province';
                      }
                      return null;
                    },
                  ),
                  _buildTextField(
                    label: 'Zip/Postal Code',
                    controller: _zipController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your zip or postal code';
                      }
                      return null;
                    },
                  ),
                ],
              ),

              // Submit Button
              ElevatedButton(
                onPressed: _submitComplaint,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build a card with form fields
  Widget _buildCard({required String title, required List<Widget> children}) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  // Helper method to build a text field
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    required String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
      ),
    );
  }
}