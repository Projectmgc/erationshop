import 'package:erationshop/user/screens/user_card.dart';
import 'package:erationshop/user/screens/user_enquiry.dart';
import 'package:erationshop/user/screens/user_notification.dart';
import 'package:erationshop/user/screens/user_outlet.dart';
import 'package:erationshop/user/screens/user_profile.dart';
import 'package:erationshop/user/screens/user_purchase.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart'; // Import the package

class UhomeScreen extends StatefulWidget {
  const UhomeScreen({super.key});

  @override
  State<UhomeScreen> createState() => _UhomeScreenState();
}

class _UhomeScreenState extends State<UhomeScreen> {
  final PageController _pageController = PageController();

  final List<Map<String, dynamic>> _cards = [
    {
      'title': 'Profile',
      'color': Colors.lightBlueAccent,
      'description': 'Manage your personal details and preferences.',
      'image': 'asset/profile.jpg',
      'page': UserProfile(), // Navigation target
    },
    {
      'title': 'Purchase',
      'color': Colors.lightGreenAccent,
      'description': 'Keep track of available inventory and supplies.',
      'image': 'asset/purchase.jpg',
      'page': UserPurchase(), // Navigation target
    },
    {
      'title': 'Outlet',
      'color': Colors.amberAccent,
      'description': 'Find and Analyse the Ration Outlets.',
      'image': 'asset/outlet.jpg',
      'page': UserOutlet(), // Navigation target
    },
    {
      'title': 'Enquiry',
      'color': Colors.pinkAccent.shade100,
      'description': 'Address and Resolve Your Complaints.',
      'image': 'asset/enquiry.jpg',
      'page': UserEnquiry(), // Navigation target
    },
    {
      'title': 'Card',
      'color': Colors.purpleAccent.shade100,
      'description': 'Manage Ration-Card related operations.',
      'image': 'asset/card.jpg',
      'page': UserCard(), // Navigation target
    },
    {
      'title': 'Notification',
      'color': Colors.tealAccent,
      'description': 'New Updations and Notifications are here.',
      'image': 'asset/notification.jpg',
      'page': UserNotification(), // Navigation target
    },
  ];

  void _onCardTapped(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  void gotoprofile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return UserProfile();
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromARGB(255, 245, 184, 93),
                  const Color.fromARGB(255, 233, 211, 88),
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

              // Header Section with adjusted spacing and font size
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    ClipOval(
                      child: 
                      Image.asset(
                        'asset/logo.jpg',
                        width: 50,
                        height: 50,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'HOME  ',
                      style: GoogleFonts.merriweather(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 26.0, // Increased font size
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      icon: CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color.fromARGB(255, 85, 50, 4),
                        child: Icon(Icons.person, color: const Color.fromARGB(255, 250, 250, 250)),
                      ),
                      onPressed: gotoprofile,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 50), // Increased spacing from the top
              // Cards Section with PageView.builder
              Expanded(
                child: Column(
                  children: [
                    // PageView Section
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _cards.length,
                        itemBuilder: (context, index) {
                          final card = _cards[index];
                          return _buildPageCard(card);
                        },
                      ),
                    ),
                    // Dot indicator (SmoothPageIndicator)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: SmoothPageIndicator(
                        controller: _pageController,  // Controller to sync with PageView
                        count: _cards.length,  // Number of dots
                        effect: ExpandingDotsEffect(
                          dotWidth: 10,
                          dotHeight: 10,
                          activeDotColor: Colors.deepPurpleAccent,  // Active dot color
                          dotColor: Colors.white.withOpacity(0.5),  // Inactive dot color
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPageCard(Map<String, dynamic> card) {
    return Center(
      child: GestureDetector(
        onTap: () => _onCardTapped(card['page']),
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
                      color: Colors.white,
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
                        color: Colors.white.withOpacity(0.9),
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
