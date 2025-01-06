import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:erationshop/owner/screens/owner_enquiry.dart';
import 'package:erationshop/owner/screens/owner_notification.dart';
import 'package:erationshop/owner/screens/owner_outlet.dart';
import 'package:erationshop/owner/screens/owner_purchase.dart';
import 'package:erationshop/owner/screens/owner_profile.dart';

class OwnerHomeScreen extends StatefulWidget {
  const OwnerHomeScreen({super.key});

  @override
  State<OwnerHomeScreen> createState() => _OwnerHomeScreenState();
}

class _OwnerHomeScreenState extends State<OwnerHomeScreen> {
  final PageController _pageController = PageController();
  String shop_id = ''; // To hold the shop_id from SharedPreferences

  // Updated card list to navigate to correct pages
  final List<Map<String, dynamic>> _cards = [
    {
      'title': 'Purchase',
      'color': Colors.lightGreenAccent,
      'description': 'Keep track of available inventory and supplies.',
      'image': 'asset/purchase.jpg',
      'page': PurchasePage(), // Navigation target
    },
    {
      'title': 'Outlet',
      'color': Colors.amberAccent,
      'description': 'Find and Analyse the Ration Outlets.',
      'image': 'asset/outlet.jpg',
      'page': OutletPage(), // Navigation target
    },
    {
      'title': 'Converse',
      'color': Colors.pinkAccent.shade100,
      'description': 'Address and Resolve Your Complaints.',
      'image': 'asset/enquiry.jpg',
      'page': null, // Handle separately (for Enquiry)
    },
    {
      'title': 'Notification',
      'color': Colors.tealAccent,
      'description': 'New Updates and Notifications are here.',
      'image': 'asset/notification.jpg',
      'page': OwnerNotification(), // Navigation target
    },
  ];

  @override
  void initState() {
    super.initState();
    _getShopId();
  }

  // Fetch shop_id from SharedPreferences
  void _getShopId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      shop_id = prefs.getString('shop_id') ?? '';
    });
  }

  // Handle card tap and navigate accordingly
  void _onCardTapped(BuildContext context, Widget? page) {
    if (page != null) {
      // Navigate to the associated page directly
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => page),
      );
    } else {
      // Handle 'Converse' card by passing the shopId
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              EnquiryPage(shopId: shop_id), // Correctly pass the shopId to EnquiryPage
        ),
      );
    }
  }

  // Navigate to owner profile page
  void _goToProfile() {
    if (shop_id.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfilePage(shopId: shop_id)),
      );
    }
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
              SizedBox(height: 20), // Adjusted top margin
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
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 26.0, // Increased font size
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      icon: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          color: Colors.deepPurpleAccent,
                        ),
                      ),
                      onPressed: _goToProfile, // Navigate to profile screen
                    ),
                  ],
                ),
              ),
              SizedBox(height: 50), // Increased spacing from the top

              // Cards Section with PageView.builder
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _cards.length,
                  itemBuilder: (context, index) {
                    final card = _cards[index];
                    return _buildPageCard(context, card);
                  },
                ),
              ),
              // Dot indicator (SmoothPageIndicator)
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: SmoothPageIndicator(
                  controller: _pageController, // Sync with PageView
                  count: _cards.length,
                  effect: ExpandingDotsEffect(
                    dotWidth: 10,
                    dotHeight: 10,
                    activeDotColor: Colors.deepPurpleAccent,
                    dotColor: Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
            ],
          ),
        ],
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
                    style: TextStyle(
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
                      style: TextStyle(
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
