import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:scb/customer/userform.dart';

class HomePg extends StatefulWidget {
  const HomePg({super.key});

  @override
  State<HomePg> createState() => _HomePgState();
}

class _HomePgState extends State<HomePg> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      // Scaffold widget providing the structure for the home page
      // appBar: AppBar(
      //   // App bar with the title 'Home Page'
      //   title: Text('Home Page'),
      // ),
      body: SingleChildScrollView(
        // SingleChildScrollView to make the body scrollable
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // Main column to hold all the content
          children: <Widget>[
            // Container for the header section
            Container(
              width: screenWidth,
              decoration: BoxDecoration(
                color: Colors.lightBlueAccent,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                // Row for the header content
                child: Row(
                  children: [
                    // User avatar
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        backgroundImage:
                            AssetImage('assets/wahingmachine2.png'),
                        radius: 25,
                      ),
                    ),
                    // Username text with expanded to fill remaining space
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          'Username',
                          style: TextStyle(fontSize: 25),
                        ),
                      ),
                    ),
                    // Notification icon
                    Icon(Icons.notifications),
                  ],
                ),
              ),
            ),
            // SizedBox for spacing
            SizedBox(height: 20),
            // Text for Support of the card
            Row(
              children: [
                SizedBox(width: 10),
                Text(
                  'Select the service from the below options',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            // Row for service cards
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // First service card
                Flexible(
                  child: Card(
                    elevation: 10,
                    shadowColor: Colors.black,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            Color(0xFFB4E380),
                            Color(0xFFF6FB7A),
                            Color(0xFFB4E380)
                          ],
                          center: Alignment.center,
                          radius: 0.85,
                          focal: Alignment.center,
                          focalRadius: 0.1,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Column(
                        children: [
                          // Space at the top
                          SizedBox(height: 10),
                          // Image for the service
                          Image(
                            image: AssetImage('assets/wahingmachine2.png'),
                            height: screenHeight * 0.25,
                            width: screenWidth * 0.4,
                          ),
                          // Space between
                          SizedBox(height: 10),
                          // Description container
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MyApp()),
                                    );
                                  },
                                  child: AutoSizeText(
                                    'Washing Machine',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    minFontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Space at the bottom
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ),
                // Second service card
                Flexible(
                  child: Card(
                    elevation: 10,
                    shadowColor: Colors.black,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            Color(0xFF201E43),
                            Color(0xFF134B70),
                            Color(0xFF201E43),
                          ],
                          center: Alignment.center,
                          radius: 0.85,
                          focal: Alignment.center,
                          focalRadius: 0.1,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Column(
                        children: [
                          // Space at the top
                          SizedBox(height: 10),
                          // Image for the service
                          Image(
                            image: AssetImage('assets/fridge.png'),
                            height: screenHeight * 0.25,
                            width: screenWidth * 0.45,
                          ),
                          // Space between
                          SizedBox(height: 10),
                          // Description container
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MyApp()),
                                    );
                                  },
                                  child: AutoSizeText(
                                    'Refrigerator',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    minFontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Space at the bottom
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Second Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // First service card
                Flexible(
                  child: Card(
                    elevation: 10,
                    shadowColor: Colors.black,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            Color(0xFF201E43),
                            Color(0xFF134B70),
                            Color(0xFF201E43),
                          ],
                          center: Alignment.center,
                          radius: 0.85,
                          focal: Alignment.center,
                          focalRadius: 0.1,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Column(
                        children: [
                          // Space at the top
                          SizedBox(height: 10),
                          // Image for the service
                          Image(
                            image: AssetImage('assets/AC.png'),
                            height: screenHeight * 0.25,
                            width: screenWidth * 0.4,
                          ),
                          // Space between
                          SizedBox(height: 10),
                          // Description container
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MyApp()),
                                    );
                                  },
                                  child: AutoSizeText(
                                    'Air Conditioner',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    minFontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Space at the bottom
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ),
                // Second service card
                Flexible(
                  child: Card(
                    elevation: 10,
                    shadowColor: Colors.black,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            Color(0xFFB4E380),
                            Color(0xFFF6FB7A),
                            Color(0xFFB4E380)
                          ], // Using the specified colors
                          center: Alignment.center,
                          radius: 0.85,
                          focal: Alignment.center,
                          focalRadius: 0.1,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(
                            10)), // To match the Card's borderRadius
                      ),
                      child: Column(
                        children: [
                          // Space at the top
                          SizedBox(height: 10),
                          // Image for the service
                          Image(
                            image: AssetImage('assets/oven.png'),
                            height: screenHeight * 0.25,
                            width: screenWidth * 0.45,
                          ),
                          // Space between
                          SizedBox(height: 10),
                          // Description container
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MyApp()),
                                    );
                                  },
                                  child: AutoSizeText(
                                    'Microwaves',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    minFontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Space at the bottom
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      //Bottom Navigation Bar
      // Bottom navigation bar
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black,
        backgroundColor: Colors.blueAccent,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
