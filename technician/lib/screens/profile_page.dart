import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    // Your home page content widgets go here
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[850],
        title: Text(
          'Technician Home',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: _pages[_currentIndex],
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.grey[850],
              ),
              child: Text(
                'Menu',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.grey),
              title: Text('Profile', style: GoogleFonts.poppins()),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Business',
          ),
        ],
        currentIndex: _currentIndex,
        selectedItemColor: Colors.grey[850],
        unselectedItemColor: Colors.grey[500],
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
      ),
    );
  }
}

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
      const SnackBar(content: Text('Profile info saved successfully!')),
    );
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
          _phoneController.text = data['phone'];
          _addressController.text = data['address'];
          _cityController.text = data['city'];
          _stateController.text = data['state'];
          _zipController.text = data['zip'];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading profile info: $e')),
      );
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
    setState(() {
      _isLoading = true;
    });

    try {
      Position position = await _determinePosition();
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}&addressdetails=1');

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'];
        String city = address['city'] ?? '';
        String state = address['state'] ?? '';
        String postalCode = address['postcode'] ?? '';

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
        _isLoading = false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Colors.grey[850],
      //   title: const Text('Profile', style: TextStyle(color: Colors.white)),
      // ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              _buildTextField(controller: _nameController, label: 'Full name'),
              const SizedBox(height: 16),
              _buildTextField(
                  controller: _emailController,
                  label: 'Username',
                  enabled: false),
              const SizedBox(height: 16),
              _buildTextField(controller: _phoneController, label: 'Phone'),
              const SizedBox(height: 16),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _fetchAddressFromLocation,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity,
                            45), // Adjusted height for smaller button
                        backgroundColor: Colors.grey[800],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              20.0), // Adjust to make the button a bit smaller
                        ),
                      ),
                      child: const Text(
                        'Fetch Address from Location',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white), // Slightly smaller text size
                      ),
                    ),
              const SizedBox(height: 16),
              _buildTextField(controller: _addressController, label: 'Address'),
              const SizedBox(height: 16),
              _buildTextField(controller: _cityController, label: 'City'),
              const SizedBox(height: 16),
              _buildTextField(controller: _stateController, label: 'State'),
              const SizedBox(height: 16),
              _buildTextField(controller: _zipController, label: 'Zip Code'),
              const SizedBox(height: 24),

              // Grey and White Themed Buttons
              // Button for 'Fetch Address from Location'

// Button for 'Save'
              ElevatedButton(
                onPressed: _saveProfileInfo,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity,
                      45), // Adjusted height for smaller button
                  backgroundColor: Colors.grey[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        20.0), // Adjust to match text field size
                  ),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(
                      fontSize: 16, color: Colors.white), // Smaller text size
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      style: const TextStyle(fontSize: 14), // Adjust font size of input text
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
            fontSize: 14, color: Colors.grey), // Smaller font for label
        contentPadding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 15), // Reduced padding for smaller input field
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
              15.0), // Rounded corners, adjust to preference
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
