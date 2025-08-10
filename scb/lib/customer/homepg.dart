import 'dart:async'; // Import for auto-scrolling
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scb/customer/Complaint_history.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../customer/complaint_page.dart';
import '../screens/profile_page.dart';
import 'complaint_form.dart';
import 'complaint_status.dart';
import 'setting.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Controllers for drawer text
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _pages = [
    const HomePageContent(),
    const ComplaintPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _loadLastSelectedIndex();
    _loadProfileData();
  }

  Future<void> _loadLastSelectedIndex() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentIndex = prefs.getInt('lastSelectedIndex') ?? 0;
    });
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
      });
    }
  }

  void _onTabTapped(int index) async {
    setState(() {
      _currentIndex = index;
    });
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('lastSelectedIndex', index);
  }

  Future<bool> _onWillPop() async {
    if (_currentIndex != 0) {
      setState(() {
        _currentIndex = 0;
      });
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: _scaffoldKey,
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: const Color(0xFF795548),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    const SizedBox(height: 16),
                    Text(
                      _nameController.text.isNotEmpty
                          ? _nameController.text
                          : 'SCB',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _emailController.text.isNotEmpty
                          ? _emailController.text
                          : 'User App',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.history, color: Color(0xFF795548)),
                title: Text(
                  'Complaint History',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF795548),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ComplaintHistoryPage()),
                  );
                },
              ),
              const Divider(
                height: 1,
                thickness: 1,
                indent: 16,
                endIndent: 16,
                color: Colors.grey,
              ),
              ListTile(
                leading: const Icon(Icons.settings, color: Color(0xFF795548)),
                title: Text(
                  'Settings',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF795548),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SettingsPage()),
                  );
                },
              ),
            ],
          ),
        ),
        body: _pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart), label: 'Complaints'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key});

  @override
  _HomePageContentState createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late PageController _pageController; // Declare the controller as late
  int _currentPage = 0;
  Timer? _carouselTimer;

  @override
  void initState() {
    super.initState();

    // Initialize the controller
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward();

    // Initialize _pageController after everything else is initialized
    _pageController = PageController();

    // Start auto-scroll
    _startAutoScroll();
  }

  @override
  void dispose() {
    _controller.dispose();
    _pageController.dispose();
    _carouselTimer?.cancel(); // Cancel the timer to prevent issues
    super.dispose();
  }

  void _startAutoScroll() {
    _carouselTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted && _pageController.hasClients) {
        // Ensure mounted check
        _currentPage++;
        if (_currentPage == 3) _currentPage = 0; // Reset to first page
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                  height: screenSize.height * 0.1), // Leave space for header

              // Offers Carousel Section
              SizedBox(
                height: screenSize.height * 0.25,
                child: PageView(
                  controller: _pageController, // Safe to use now
                  children: [
                    _buildOfferCard('Diwali Sale: 20% OFF', Colors.orange),
                    _buildOfferCard('Service Discount: 15% OFF', Colors.blue),
                    _buildOfferCard(
                        'Winter Special: Free Inspection', Colors.green),
                  ],
                ),
              ),

              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: screenSize.width * 0.04),
                child: Text(
                  "Select the service from the below options",
                  style: GoogleFonts.poppins(
                    fontSize: screenSize.width * 0.045,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(
                height: screenSize.height * 0.7,
                child: GridView.builder(
                  padding: EdgeInsets.all(screenSize.width * 0.04),
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: screenSize.width > 600 ? 3 : 2,
                    crossAxisSpacing: screenSize.width * 0.04,
                    mainAxisSpacing: screenSize.width * 0.04,
                    childAspectRatio:
                        screenSize.width / (screenSize.height / 1.8),
                  ),
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return SlideTransition(
                      position: _offsetAnimation,
                      child: _buildServiceCard(
                        index == 0
                            ? 'Washing Machine'
                            : index == 1
                                ? 'Refrigerator'
                                : index == 2
                                    ? 'Air Conditioner'
                                    : 'Microwave',
                        index == 0
                            ? 'assets/wahingmachine2.png'
                            : index == 1
                                ? 'assets/fridge.png'
                                : index == 2
                                    ? 'assets/AC.png'
                                    : 'assets/oven.png',
                        screenSize,
                        context,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // Top Header that remains fixed
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF795548),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30.0),
                bottomRight: Radius.circular(30.0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            height: screenSize.height * 0.1,
            padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.04),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
                const SizedBox(width: 16),
                Text(
                  'Welcome to SCB',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: screenSize.width * 0.06,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOfferCard(String text, Color color) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      width: 300,
      child: Center(
        child: Text(
          text,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildServiceCard(
      String service, String imagePath, Size screenSize, BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to service-specific page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ComplaintRegistrationForm(),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              height: screenSize.height * 0.12,
              width: screenSize.width * 0.3,
            ),
            SizedBox(height: screenSize.height * 0.02),
            Text(
              service,
              style: GoogleFonts.poppins(
                fontSize: screenSize.width * 0.045,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Example service pages:
// class WashingMachinePage extends StatelessWidget {
//   const WashingMachinePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     var screenSize = MediaQuery.of(context).size;
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Washing Machine',
//           style: GoogleFonts.poppins(fontSize: screenSize.width * 0.045),
//         ),
//       ),
//       body: Center(
//         child: Text(
//           'Details for Washing Machine will be displayed here.',
//           style: GoogleFonts.poppins(fontSize: screenSize.width * 0.045),
//         ),
//       ),
//     );
//   }
// }

// class RefrigeratorPage extends StatelessWidget {
//   const RefrigeratorPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     var screenSize = MediaQuery.of(context).size;
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Refrigerator',
//           style: GoogleFonts.poppins(fontSize: screenSize.width * 0.045),
//         ),
//       ),
//       body: Center(
//         child: Text(
//           'Details for Refrigerator will be displayed here.',
//           style: GoogleFonts.poppins(fontSize: screenSize.width * 0.04),
//         ),
//       ),
//     );
//   }
// }

// class AirConditionerPage extends StatelessWidget {
//   const AirConditionerPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     var screenSize = MediaQuery.of(context).size;
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Air Conditioner',
//           style: GoogleFonts.poppins(fontSize: screenSize.width * 0.045),
//         ),
//       ),
//       body: Center(
//         child: Text(
//           'Details for Air Conditioner will be displayed here.',
//           style: GoogleFonts.poppins(fontSize: screenSize.width * 0.04),
//         ),
//       ),
//     );
//   }
// }

// class MicrowavePage extends StatelessWidget {
//   const MicrowavePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     var screenSize = MediaQuery.of(context).size;
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Microwave',
//           style: GoogleFonts.poppins(fontSize: screenSize.width * 0.045),
//         ),
//       ),
//       body: Center(
//         child: Text(
//           'Details for Microwave will be displayed here.',
//           style: GoogleFonts.poppins(fontSize: screenSize.width * 0.04),
//         ),
//       ),
//     );
//   }
// }