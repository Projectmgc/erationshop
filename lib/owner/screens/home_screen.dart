import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'owner_profile.dart';
import 'owner_purchase.dart';
import 'owner_outlet.dart';
import 'owner_enquiry.dart';
import 'owner_card.dart';
import 'owner_notification.dart';

class OwnerHomeScreen extends StatefulWidget {
  const OwnerHomeScreen({super.key});

  @override
  State<OwnerHomeScreen> createState() => _OwnerHomeScreenState();
}

class _OwnerHomeScreenState extends State<OwnerHomeScreen> {
  final PageController _pageController = PageController();

  final List<Map<String, dynamic>> _cards = [
    {
      'title': 'Purchase',
      'color': Colors.lightGreenAccent,
      'description': 'Keep track of available inventory and supplies.',
      'image': 'asset/purchase.jpg',
      'page': const PurchasePage(), // Navigation target
    },
    {
      'title': 'Outlet',
      'color': Colors.amberAccent,
      'description': 'Find and Analyse the Ration Outlets.',
      'image': 'asset/outlet.jpg',
      'page': const OutletPage(), // Navigation target
    },
    {
      'title': 'Connverse',
      'color': Colors.pinkAccent.shade100,
      'description': 'Address and Resolve Your Complaints.',
      'image': 'asset/enquiry.jpg',
      'page': const EnquiryPage(), // Navigation target
    },
    {
      'title': 'Card',
      'color': Colors.purpleAccent.shade100,
      'description': 'Manage Ration-Card related operations.',
      'image': 'asset/card.jpg',
      'page': const CardPage(), // Navigation target
    },
    {
      'title': 'Notification',
      'color': Colors.tealAccent,
      'description': 'New Updates and Notifications are here.',
      'image': 'asset/notification.jpg',
      'page': const OwnerNotification(), // Navigation target
    },
  ];

  void _onCardTapped(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  void _goToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfilePage()),
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
              // Header Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    ClipOval(
                      child: Image.asset(
                        'asset/logo.jpg',
                        width: 50,
                        height: 50,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'OWNER HOME',
                      style: GoogleFonts.merriweather(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 22.0,
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      icon: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, color: Colors.deepPurpleAccent),
                      ),
                      onPressed: _goToProfile, // Navigate to the profile screen
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
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
                        controller: _pageController, // Controller to sync with PageView
                        count: _cards.length, // Number of dots
                        effect: ExpandingDotsEffect(
                          dotWidth: 10,
                          dotHeight: 10,
                          activeDotColor: Colors.deepPurpleAccent, // Active dot color
                          dotColor: Colors.white.withOpacity(0.5), // Inactive dot color
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
