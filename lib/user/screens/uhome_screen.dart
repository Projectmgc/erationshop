import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:erationshop/user/screens/user_card.dart';
import 'package:erationshop/user/screens/user_enquiry.dart';
import 'package:erationshop/user/screens/user_notification.dart';
import 'package:erationshop/user/screens/user_outlet.dart';
import 'package:erationshop/user/screens/user_profile.dart';
import 'package:erationshop/user/screens/user_purchase.dart';
import 'package:flutter/services.dart'; // Import to use SystemNavigator.pop()

class UhomeScreen extends StatefulWidget {
  const UhomeScreen({super.key});

  @override
  State<UhomeScreen> createState() => _UhomeScreenState();
}

class _UhomeScreenState extends State<UhomeScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  final List<Map<String, dynamic>> _cards = [
    {
      'title': 'Purchase',
      'color': const Color.fromARGB(255, 1, 1, 1),
      'description': 'Keep track of available inventory and supplies.',
      'image': 'asset/purchase.jpg',
      'page': UserPurchase(), // Navigation target
    },
    {
      'title': 'Outlet',
      'color': const Color.fromARGB(255, 4, 4, 4),
      'description': 'Find and Analyse the Ration Outlets.',
      'image': 'asset/outlet.jpg',
      'page': UserOutlet(), // Navigation target
    },
    {
      'title': 'Enquiry',
      'color': const Color.fromARGB(255, 3, 3, 3),
      'description': 'Address and Resolve Your Complaints.',
      'image': 'asset/enquiry.jpg',
      'page': null, // Handle separately
    },
    {
      'title': 'Card',
      'color': const Color.fromARGB(255, 5, 5, 5),
      'description': 'Manage Ration-Card related operations.',
      'image': 'asset/card.jpg',
      'page': UserCard(), // Navigation target
    },
    {
      'title': 'Notification',
      'color': const Color.fromARGB(255, 9, 9, 9),
      'description': 'New Updations and Notifications are here.',
      'image': 'asset/notification.jpg',
      'page': NotificationsPage(), // Navigation target
    },
  ];

  String _userId = ''; // To hold the user_id from the user profile

  @override
  void initState() {
    super.initState();
    _fetchUserId();

    _pageController.addListener(() {
      // Detect the first or last page and jump to the opposite end
      if (_pageController.position.pixels <= 0) {
        _pageController.jumpToPage(_cards.length - 1); // Jump to last card
      } else if (_pageController.position.pixels >=
          _pageController.position.maxScrollExtent) {
        _pageController.jumpToPage(0); // Jump to first card
      }
    });
  }

  Future<void> _fetchUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('card_no')!; // Assuming 'card_no' is stored in SharedPreferences
  }

  // Handle the card tap event and navigate accordingly
  void _onCardTapped(BuildContext context, Widget? page) {
    if (page != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => page),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              UserEnquiry(user_id: _userId), // Pass the userId to UserEnquiry
        ),
      );
    }
  }

  // Navigate to user profile page
  void gotoprofile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserProfile()),
    );
  }

  // Handle the back button press to close the app
  Future<bool> _onWillPop() async {
    // Close the app when the back button is pressed
    SystemNavigator.pop();
    return false; // Prevent the default back navigation behavior
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop, // Custom back button behavior
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black, // Black background for the app bar
          automaticallyImplyLeading: false, // Remove default back button
          title: Row(
            children: [
              // Logo on the left
              ClipOval(
                child: Image.asset(
                  'asset/logo.jpg',
                  width: 40,
                  height: 40,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(width: 10),
              // Spacer to center the text
              Spacer(),
              // Centered "E-Ration" text
              Text(
                'E-Ration', // Change header text to "E-Ration"
                style: GoogleFonts.merriweather(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 26.0, // Adjusted font size for app bar
                ),
              ),
              Spacer(),
              // Profile icon on the right
              IconButton(
                icon: CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color.fromARGB(255, 255, 255, 254),
                  child: Icon(Icons.person, color: const Color.fromARGB(255, 8, 8, 8)),
                ),
                onPressed: gotoprofile,
              ),
            ],
          ),
        ),
        body: Stack(
          children: [
            // Background gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color.fromARGB(255, 255, 255, 255),
                    const Color.fromARGB(255, 248, 247, 245),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                // Cards Section with PageView.builder
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: null, // Infinite pages
                    itemBuilder: (context, index) {
                      final card = _cards[index % _cards.length]; // Looping
                      return _buildPageCard(context, card);
                    },
                  ),
                ),
                // Dot indicator (SmoothPageIndicator)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: SmoothPageIndicator(
                    controller: _pageController, // Controller to sync with PageView
                    count: _cards.length, // Number of dots
                    effect: ExpandingDotsEffect(
                      dotWidth: 10,
                      dotHeight: 10,
                      activeDotColor: const Color.fromARGB(255, 6, 6, 6), // Active dot color
                      dotColor: Colors.white.withOpacity(0.5), // Inactive dot color
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Card UI for each PageView item
  Widget _buildPageCard(BuildContext context, Map<String, dynamic> card) {
    return Center(
      child: GestureDetector(
        onTap: () => _onCardTapped(context, card['page']),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: card['color'].withOpacity(0.4),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  card['image'],
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.4),
                      Colors.black.withOpacity(0.1),
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(height: 20),
                  Text(
                    card['title'],
                    style: GoogleFonts.roboto(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 250, 248, 248),
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      card['description'],
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        color: const Color.fromARGB(255, 254, 254, 254).withOpacity(0.9),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
