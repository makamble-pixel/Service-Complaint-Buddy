import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../customer/homepg.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _loadEmailFromPreferences();
  }

  Future<void> _saveProfileInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final profileData = {
      'name': _nameController.text,
      'email': _emailController.text,
      'phone': _phoneController.text,
      'address': _addressController.text,
      'city': _cityController.text,
      'state': _stateController.text,
      'zip': _zipController.text,
    };
    await prefs.setString('profileInfo', jsonEncode(profileData));
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile info saved successfully!')));
  }

  Future<void> _loadProfileData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileInfo = prefs.getString('profileInfo');
      if (profileInfo != null) {
        final data = jsonDecode(profileInfo);
        setState(() {
          _nameController.text = data['name'];
          _emailController.text = data['email'];
          _addressController.text = data['address'];
          _cityController.text = data['city'];
          _stateController.text = data['state'];
          _zipController.text = data['zip'];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile info: $e')));
    }
  }

  Future<void> _loadEmailFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedEmail = prefs.getString('email');
    if (savedEmail != null) {
      setState(() {
        _emailController.text = savedEmail;
      });
    }
  }

  Future<void> _fetchAddressFromLocation() async {
    final shouldProceed = await _showConfirmationDialog();
    if (!shouldProceed) return;

    setState(() {
      _isLoading = true; // Start loading
    });

    try {
      Position position = await _determinePosition();

      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}&addressdetails=1');

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'];
        String building = address['building'] ?? '';
        String road = address['road'] ?? '';
        String suburb = address['suburb'] ?? '';
        String city = address['city'] ?? '';
        String state = address['state'] ?? '';
        String postalCode = address['postcode'] ?? '';
        String fullAddress =
            [building, road, suburb].where((s) => s.isNotEmpty).join(', ');

        setState(() {
          _cityController.text = city;
          _stateController.text = state;
          _zipController.text = postalCode;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to fetch address')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Unable to fetch address: $e')));
    } finally {
      setState(() {
        _isLoading = false; // End loading
      });
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<bool> _onWillPop() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
    return false; // Prevent the default back button action
  }

  Future<bool> _showConfirmationDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Fetch Address'),
          content: const Text(
              'This will use your current location to fetch the address. Do you want to proceed?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Return false if canceled
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Return true if proceeded
              },
              child: const Text('Proceed'),
            ),
          ],
        );
      },
    );

    return result ?? false; // Return false if result is null
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('My Profile'),
          backgroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20),
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildProfileField(_nameController, 'Full Name'),
                  const SizedBox(height: 16),
                  _buildProfileField(_emailController, 'Email'),
                  const SizedBox(height: 16),
                  _buildProfileField(_phoneController, 'Phone Number'),
                  const SizedBox(
                    height: 16,
                  ),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Center(
                          child: ElevatedButton(
                            onPressed: _fetchAddressFromLocation,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14.0, horizontal: 24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            child: const Text(
                              'Fetch Address',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 14.0),
                            ),
                          ),
                        ),
                  const SizedBox(height: 16),
                  _buildProfileField(_addressController, 'Address'),
                  const SizedBox(height: 16),
                  _buildProfileField(_cityController, 'City'),
                  const SizedBox(height: 16),
                  _buildProfileField(_stateController, 'State'),
                  const SizedBox(height: 16),
                  _buildProfileField(_zipController, 'Zip Code'),
                  const SizedBox(height: 32),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: _saveProfileInfo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            vertical: 14.0, horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Text(
                        'Save Profile',
                        style: TextStyle(color: Colors.white, fontSize: 14.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileField(TextEditingController controller, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[200],
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
