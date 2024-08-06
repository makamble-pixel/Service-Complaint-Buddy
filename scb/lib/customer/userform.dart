import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:scb/reusable files/textfieldreuse.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Submit Customer Info')),
        body: MyForm(),
      ),
    );
  }
}

class MyForm extends StatefulWidget {
  @override
  _MyFormState createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  final nameController = TextEditingController();
  final complaintController = TextEditingController();
  final customerTypeController = TextEditingController();
  final addressController = TextEditingController();
  final machineModelController = TextEditingController();
  final phoneNumberController = TextEditingController();

  Future<void> _submitData() async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.68.146:3000/customers'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'name': nameController.text,
          'complaint': complaintController.text,
          'customerType': customerTypeController.text,
          'address': addressController.text,
          'machineModel': machineModelController.text,
          'phoneNumber': phoneNumberController.text,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data submitted successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit data: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: nameController,
          decoration: InputDecoration(labelText: 'Name'),
        ),
        TextField(
          controller: complaintController,
          decoration: InputDecoration(labelText: 'Complaint'),
        ),
        TextField(
          controller: customerTypeController,
          decoration: InputDecoration(labelText: 'Customer Type'),
        ),
        TextField(
          controller: addressController,
          decoration: InputDecoration(labelText: 'Address'),
        ),
        TextField(
          controller: machineModelController,
          decoration: InputDecoration(labelText: 'Machine Model'),
        ),
        TextField(
          controller: phoneNumberController,
          decoration: InputDecoration(labelText: 'Phone Number'),
          keyboardType: TextInputType.phone,
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: _submitData,
          child: Text('Submit'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    complaintController.dispose();
    customerTypeController.dispose();
    addressController.dispose();
    machineModelController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }
}
